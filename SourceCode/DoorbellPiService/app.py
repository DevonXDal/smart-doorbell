from decouple import AutoConfig
from flask import Flask, abort, request
from datetime import datetime, timezone

import twilio.jwt.access_token
import twilio.jwt.access_token.grants
import twilio.rest

from system_watchers import doorbell_watcher, mock_watcher
from main_server_handler import MainServerHandler


# https://www.geeksforgeeks.org/get-utc-timestamp-in-python/ - mktime gives local time but utc epoch is needed
def convert_datetime_to_utc_epoch_int(dt: datetime):
    utc_datetime = dt.replace(tzinfo=timezone.utc)
    return int(utc_datetime.timestamp())


current_time = datetime.utcnow()

app = Flask(__name__)

# Converting datetime to unix time: https://www.geeksforgeeks.org/how-to-convert-datetime-to-unix-timestamp-in-python/
last_doorbell_activation_unix = convert_datetime_to_utc_epoch_int(
    current_time)  # Used to indicate to the server the last time that the button was pressed
is_in_twilio_call = False  # Tracks whether a call is currently ongoing
current_server_JWT = None  # Tracks the current JWT used to connect to the main Web server for requests.
server_handler: MainServerHandler = None
system_watcher = None
config = AutoConfig(search_path='./.env')
isOnRaspberryPi = config('IsOnRaspberryPi', default=False, cast=bool)

# Create a Twilio client - Documentation for this at: https://www.twilio.com/docs/video/tutorials/get-started-with-twilio-video-python-flask-server
account_sid = config('TWILIO_ACCOUNT_SID')
api_key = config('TWILIO_API_KEY_SID')
api_secret = config('TWILIO_API_KEY_SECRET')
twilio_client = twilio.rest.Client(api_key, api_secret, account_sid)


def setup_services():
    global server_handler
    server_handler = MainServerHandler()
    server_handler.try_login(last_doorbell_activation_unix)

    global system_watcher
    if isOnRaspberryPi:
        system_watcher = doorbell_watcher.DoorbellWatcher(server_handler)
    else:
        system_watcher = mock_watcher.MockWatcher(server_handler)

# https://stackoverflow.com/questions/22251038/how-to-limit-access-to-flask-for-a-single-ip-address - Requests from only the server
@app.before_request
def allow_server_only_rule():
    if request.remote_addr != config('UseServerIpAddress', default='127.0.0.1'):
        abort(403)  # Returns a Forbidden response

# This checks that the doorbell can be reached during testing.
@app.route('/', methods=['GET'])
def hello():
    return {'Confirmation': 'Successful Connection'}

# Notifies the doorbell that someone has decided to join the call.
# This also provides the token necessary to start and join the call.
# This is only necessary when the doorbell has not been previously asked to join the call.
@app.route('/NotifyOfAppAnswer', methods=['POST'])
def notify_off_app_answer():
    twilio_access_token = request.json['Token']
    twilio_video_call_room = request.json['RoomName']

# Needed for the server to request status updates on the doorbell to update app information.
# No response from this means that the server is unable to reach the doorbell.
@app.route('/FetchStatusUpdate/', methods=['GET'])
def fetch_status_update():
    state = 'Error'
    is_awaiting_answer = (convert_datetime_to_utc_epoch_int(datetime.utcnow()) - last_doorbell_activation_unix) < 60

    if is_in_twilio_call:
        state = 'IN_CALL'
    elif is_awaiting_answer:
        state = 'AWAITING'
    else:
        state = 'IDLE'
    return {'State': state}


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    setup_services()

    # https://pypi.org/project/python-decouple/ - Environment variable usage from env file
    app.run(port=config('UseDoorbellPort', default=4500, cast=int))

    system_watcher.end_program()

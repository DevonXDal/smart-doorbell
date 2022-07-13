from decouple import RepositoryEnv, AutoConfig
from flask import Flask, request, render_template, url_for, redirect
from datetime import datetime, timedelta, date, time
import time

import doorbell_watcher
from main_server_handler import MainServerHandler

current_time = datetime.utcnow()

app = Flask(__name__)

# Converting datetime to unix time: https://www.geeksforgeeks.org/how-to-convert-datetime-to-unix-timestamp-in-python/
last_doorbell_activation_unix = time.mktime(
    current_time.timetuple())  # Used to indicate to the server the last time that the button was pressed
is_in_twilio_call = False  # Tracks whether a call is currently ongoing
current_server_JWT = None  # Tracks the current JWT used to connect to the main Web server for requests.
server_handler = None
config = AutoConfig(search_path='./.env')
isOnRaspberryPi = config('IsOnRaspberryPi', default=False, cast=bool)

def setup_services():
    server_handler = MainServerHandler()

    server_handler.try_login(last_doorbell_activation_unix)


# This checks that the doorbell can be reached during testing.
@app.route('/', methods=['GET'])
def hello():
    return {'Confirmation': 'Successful Connection'}


# Needed for the server to request status updates on the doorbell to update app information.
# No response from this means that the server is unable to reach the doorbell.
@app.route('/FetchStatusUpdate/', methods=['GET'])
def fetch_status_update():
    state = 'Error'
    is_awaiting_answer = (time.mktime(datetime.utcnow().timetuple()) - last_doorbell_activation_unix) > 60

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
    if isOnRaspberryPi:
        doorbell_watcher.setup()

    app.run(port=config('UseDoorbellPort', default=4500, cast=int))

    if isOnRaspberryPi:
        doorbell_watcher.endprogram()
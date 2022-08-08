import os

from aioflask import Flask, abort, request, render_template
from datetime import datetime

import src.app
from src.app_data import AppData
from src.handlers.web_browser_handler import WebBrowserHandler
from src.helper_functions import convert_datetime_to_utc_epoch_int, get_placement_html_filename_and_path
from src.system_watchers import mock_watcher, doorbell_watcher
from src.handlers.main_server_handler import MainServerHandler

app = Flask(__name__)
app_data = AppData()


def setup_services():
    app_data.server_handler = MainServerHandler(app_data)
    app_data.server_handler.try_login(app_data.time_turned_on_unix)
    app_data.web_browser_handler = WebBrowserHandler(app_data.config)

    if app_data.isOnRaspberryPi:
        app_data.system_watcher = doorbell_watcher.DoorbellWatcher(app_data.server_handler, app_data)
    else:
        app_data.system_watcher = mock_watcher.MockWatcher(app_data.server_handler, app_data)


# https://stackoverflow.com/questions/22251038/how-to-limit-access-to-flask-for-a-single-ip-address - Requests from only the server
@app.before_request
def allow_server_only_rule():
    if request.remote_addr != app_data.config('UseServerIpAddress', default='127.0.0.1'):
        abort(403)  # Returns a Forbidden response


# This checks that the doorbell can be reached during testing.
@app.route('/', methods=['GET'])
def hello():
    return {'Confirmation': 'Successful Connection'}


# Notifies the doorbell that someone has decided to join the call.
# This also provides the token necessary to start and join the call.
# This is only necessary when the doorbell has not been previously asked to join the call.
@app.route('/NotifyOfAppAnswer/', methods=['POST'])
async def notify_off_app_answer():
    twilio_access_token = request.json['Token']
    twilio_video_call_room = request.json['RoomName']

    connection_data = {'token': twilio_access_token, 'room_name': twilio_video_call_room}
    rendered_page = render_template('join_call.html', data=connection_data)
    filename_and_path = get_placement_html_filename_and_path(app_data.config)

    try:
        # https://www.w3schools.com/python/python_file_write.asp
        rendered_html_file = open(filename_and_path, 'w') # 'a' Appends but 'w' does an overwrite
        rendered_html_file.write(rendered_page)
        rendered_html_file.close()

        await app_data.web_browser_handler.handle_video_chat(filename_and_path, app_data)

        # https://stackoverflow.com/questions/26079754/flask-how-to-return-a-success-status-code-for-ajax-call - Philip Bergstrom
        return {}  # Yeilds a no data OK(200) response

    except OSError:
        abort(500)


# Needed for the server to request status updates on the doorbell to update app information.
# No response from this means that the server is unable to reach the doorbell.
@app.route('/FetchStatusUpdate/', methods=['GET'])
def fetch_status_update():
    state = 'Error'
    test1 = convert_datetime_to_utc_epoch_int(datetime.utcnow())
    test2 = app_data.last_doorbell_activation_unix
    print(f'NOW: {test1}, LAST: {test2}, TOTAL: {test1 - test2}')
    is_awaiting_answer = convert_datetime_to_utc_epoch_int(
        datetime.utcnow()) - app_data.last_doorbell_activation_unix <= 60

    if app_data.is_in_twilio_call:
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
    app.run(port=app_data.config('UseDoorbellPort', default=4500, cast=int))

    app_data.system_watcher.end_program()

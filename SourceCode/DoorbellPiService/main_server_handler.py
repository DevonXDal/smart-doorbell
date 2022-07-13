import sys

from decouple import AutoConfig
import requests, re, uuid, socket, time

import app


### This MainServerHandler class handles all of the calls made to the Web server to report information about this doorbell.
### This allows the main server to see which doorbells are active and list them for viewing by app users.
### This also handles the authentication/authorization process that is done to make requests to the main Web server.
###
### Author: Devon X. Dalrymple
### Version: 2022-07-11
class MainServerHandler:

    def __init__(self):
        pass

    def try_login(self, time_turned_on_unix):

        path = '/api/Authentication/login'

        # https://www.geeksforgeeks.org/extracting-mac-address-using-python/ - The MAC address is the attempt to make each doorbell unique
        login_json = {
            'deviceUUID': ':'.join(re.findall('..', '%012x' % uuid.getnode())),
            'displayName': app.config('DisplayName', default='Unnamed Doorbell'),
            'deviceType': 'Doorbell',
            'password': app.config('UseServerPassword'),
            'ipAddress': socket.gethostbyname(socket.gethostname()),
            'port': app.config('UseDoorbellPort', default='4500', cast=int),
            'lastTurnedOn': int(time_turned_on_unix)
        }

        try:
            result = requests.post(url=self._get_combined_server_url(path), allow_redirects=True, json=login_json, timeout=10)

            if result.status_code == 200:
                app.current_server_JWT = result.json().get('token')
            else:
                # Functionality is missing due to an incorrect password or ban. There is nothing further to be done
                sys.exit(
                    f'Could not login to the server successfully, thus the doorbell unable to function. Server Code: {result.status_code}')
        except Exception as e:
            # The server is not responding due to a network issue
            print(e)
            time.sleep(15)
            self.try_login(time_turned_on_unix)

    # This is used by the doorbell app whenever the button has been pressed, it was not previously awaiting an answer, and the picture has already been taken.
    # This is done to seperate the request to server from the hardware activation code.
    def declare_awaiting_answer(self, doorbell_image_file_path):
        # https://stackoverflow.com/questions/68477/send-file-using-post-from-a-python-script - Piotr Dobrogost
        with open(doorbell_image_file_path, 'rb') as image_file: # This opens the saved image file (jpeg, png, gif, etc.) as binary for reading, hence 'rb'
            pass

    # This is used to follow DRY since most requests to the main Web server will fail due to a lack of proper credentials.
    def _get_formatted_bearer_token_header(self):
        return {'Authorization': f'Bearer {app.current_server_JWT}'}

    def _get_http_type(self):
        if app.config('UseUnsecureHTTP', default=False, cast=bool):
            return 'http'
        else:
            return 'https'

    # This requires the path to include the leading '/' (like /weather/get and no weather/get
    def _get_combined_server_url(self, path):
        return f'{self._get_http_type()}://{app.config("UseServerIpAddress")}:{app.config("UseServerPort")}{path}'
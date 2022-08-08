import re
import uuid
from datetime import datetime

from decouple import AutoConfig

from src.helper_functions import convert_datetime_to_utc_epoch_int


class AppData:
    def __init__(self):
        self.current_time = datetime.utcnow()
        self.time_turned_on_unix: int = convert_datetime_to_utc_epoch_int(
            self.current_time)
        self.last_doorbell_activation_unix: int = self.time_turned_on_unix - 61  # Used to indicate to the server the last time that the button was pressed, the -61 offset prevents misreads from the server when the doorbell is first started.
        self.is_in_twilio_call = False  # Tracks whether a call is currently ongoing
        self.current_server_JWT = None  # Tracks the current JWT used to connect to the main Web server for requests.
        self.server_handler = None  # Types are removed to prevent circular imports.
        self.system_watcher = None
        self.web_browser_handler = None
        self.config = AutoConfig(search_path='./.env')
        self.isOnRaspberryPi = self.config('IsOnRaspberryPi', cast=bool)
        self.uuid = ':'.join(re.findall('..', str(hex(uuid.getnode()))))  # Gets the MAC address as a 48bit integer, converts to hexadecimal, and then formats like a MAC address.

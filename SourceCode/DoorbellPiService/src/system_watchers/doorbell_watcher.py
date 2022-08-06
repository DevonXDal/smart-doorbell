from src.app_data import AppData

try:  # Wait, you can do this? Neat. https://stackoverflow.com/questions/3131217/error-handling-when-importing-modules
    import RPi.GPIO as GPIO
except ImportError:
    pass

import os

from src import helper_functions
from src.main_server_handler import MainServerHandler


class DoorbellWatcher:
    def __init__(self, server_handler: MainServerHandler, app_data: AppData):
        self.app_data = app_data
        self._buttonOut = self.app_data.config('UsingGPIOPinForButtonOut', default=18, cast=int)
        self._buttonIn = self.app_data.config('UsingGPIOPinForButtonIn', default=16, cast=int)
        self.server_handler = server_handler

        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(self._buttonIn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
        GPIO.setup(self._buttonOut, GPIO.OUT, initial=GPIO.HIGH)

        # True whenever the button is first being pressed as the state of the in GPIO goes from 0 to 1.
        # It is rising whenever power starts reaching the in GPIO from the out GPIO
        # http://raspi.tv/2013/how-to-use-interrupts-with-python-on-the-raspberry-pi-and-rpi-gpio-part-2 - Documentation
        GPIO.add_event_detect(self._buttonIn, GPIO.RISING, callback=self._fetch_picture())

    def join_twilio_call(self, rendered_page: str):
        pass

    def end_program(self):
        GPIO.cleanup()

    def _fetch_picture(self):
        filepath = helper_functions.get_placement_file_path(self.app_data.config)
        os.system(f'libcamera-jpeg -o {filepath}')

        self.server_handler.declare_awaiting_answer(filepath)

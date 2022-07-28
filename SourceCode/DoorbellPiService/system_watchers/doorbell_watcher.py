import helper_functions

try:  # Wait, you can do this? Neat. https://stackoverflow.com/questions/3131217/error-handling-when-importing-modules
    import RPi.GPIO as GPIO
except ImportError:
    pass

import os
import time
from threading import Thread

import app
from main_server_handler import MainServerHandler


class DoorbellWatcher:
    def __init__(self, server_handler: MainServerHandler):
        self._buttonOut = app.config('UsingGPIOPinForButtonOut', default=18, cast=int)
        self._buttonIn = app.config('UsingGPIOPinForButtonIn', default=16, cast=int)
        self.server_handler = server_handler

        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(self._buttonIn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
        GPIO.setup(self._buttonOut, GPIO.OUT, initial=GPIO.HIGH)

        # True whenever the button is first being pressed as the state of the in GPIO goes from 0 to 1.
        # It is rising whenever power starts reaching the in GPIO from the out GPIO
        # http://raspi.tv/2013/how-to-use-interrupts-with-python-on-the-raspberry-pi-and-rpi-gpio-part-2 - Documentation
        GPIO.add_event_detect(self._buttonIn, GPIO.RISING, callback=self._fetch_picture())

    def end_program(self):
        GPIO.cleanup()

    def _fetch_picture(self):
        filepath = helper_functions.get_placement_file_path()
        os.system(f'libcamera-jpeg -o {filepath}')

        self.server_handler.declare_awaiting_answer(filepath)

try:  # Wait, you can do this? Neat. https://stackoverflow.com/questions/3131217/error-handling-when-importing-modules
    import RPi.GPIO as GPIO
except ImportError:
    pass

import os
import time

import app

buttonOut = None  # This will attempt to output power, this will fail to generate current unless the button is pressed
buttonIn = None  # This will serve to watch for incoming power, if there is, the button is pressed

def setup():
    buttonOut = app.config('UsingGPIOPinForButtonOut', default=18, cast=int)
    buttonIn = app.config('UsingGPIOPinForButtonIn', default=16, cast=int)

    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(buttonIn, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
    GPIO.setup(buttonOut, GPIO.OUT, initial=GPIO.HIGH)

def loop():
    while True:
        button_state = GPIO.input(buttonIn)

        if  button_state == True:
            os.system('raspistill -o image.jpg')
            print('Button Pressed...')

            while GPIO.input(buttonIn) == True:
                time.sleep(0.2)

def endprogram():
    GPIO.cleanup()
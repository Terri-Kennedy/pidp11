#! /usr/bin/env python
#
# Partly based on PiDP1170Test.py by Neil Higgins
#
# Make sure we put the front panel back to tristate and all LEDS off on exit

import RPi.GPIO as GPIO

# some constants
LED_ROW_GPIOs = [20, 21, 22, 23, 24, 25]
COLUMN_GPIOs = [26, 27, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
SWITCH_ROW_GPIOs = [16, 17, 18]

# Function to put all rows and columns into tristate mode
def tristate_all():
    for a_row in LED_ROW_GPIOs:
         GPIO.setup(a_row, GPIO.IN, GPIO.PUD_OFF)
    for a_row in SWITCH_ROW_GPIOs:
        GPIO.setup(a_row, GPIO.IN, GPIO.PUD_OFF)
    for a_column in COLUMN_GPIOs:
        GPIO.setup(a_column, GPIO.IN, GPIO.PUD_OFF)

# Initialize, turn all LEDS off, exit
GPIO.setmode(GPIO.BCM)
tristate_all()
GPIO.cleanup()

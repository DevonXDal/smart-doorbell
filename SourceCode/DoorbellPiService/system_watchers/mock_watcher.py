import os
import keyboard

import cv2

import app
import helper_functions
from main_server_handler import MainServerHandler


class MockWatcher:
    def __init__(self, server_handler: MainServerHandler):
        keyboard.add_hotkey('ctrl+alt+p', lambda: self._handle_picture_and_send())
        self.server_handler = server_handler

    def end_program(self):
        pass

    def _handle_picture_and_send(self):
        mock_cam = cv2.VideoCapture(0)  # Requires the testing device to possess a webcam of similar form. DroidCam cam can serve as a temporary if necessary

        # https://stackoverflow.com/questions/4179220/capture-single-picture-with-opencv - Take and save single frame from webcam
        _, frame = mock_cam.read()
        filepath = helper_functions.get_placement_file_path()

        cv2.imwrite(filepath, frame)
        self.server_handler.declare_awaiting_answer(filepath)
        mock_cam.release()


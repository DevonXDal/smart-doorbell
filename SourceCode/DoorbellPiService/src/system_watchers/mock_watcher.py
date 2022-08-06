import keyboard

import cv2

from src import helper_functions
from src.app_data import AppData
from src.main_server_handler import MainServerHandler


class MockWatcher:
    def __init__(self, server_handler: MainServerHandler, app_data: AppData):
        self.app_data = app_data
        keyboard.add_hotkey('ctrl+alt+p', lambda: self._handle_picture_and_send())
        self.server_handler = server_handler

    def join_twilio_call(self, rendered_page: str):
        pass

    def end_program(self):
        pass

    def _handle_picture_and_send(self):
        mock_cam = cv2.VideoCapture(0)  # Requires the testing device to possess a webcam of similar form. DroidCam cam can serve as a temporary if necessary

        # https://stackoverflow.com/questions/4179220/capture-single-picture-with-opencv - Take and save single frame from webcam
        _, frame = mock_cam.read()
        filepath = helper_functions.get_placement_file_path(self.app_data.config)

        cv2.imwrite(filepath, frame)
        self.server_handler.declare_awaiting_answer(filepath)
        mock_cam.release()


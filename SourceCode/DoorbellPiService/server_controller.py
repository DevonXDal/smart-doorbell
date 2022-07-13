from flask import Flask

import app


class ServerController:
    def __init__(self, flask_app):
        self.flask_app = flask_app

    @app.app.route()
    def fetch_current_status(self):
        pass



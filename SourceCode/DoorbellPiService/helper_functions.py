import os
from datetime import datetime

import app


# This is used to find a place to put a new image file. Image filenames are decided by the date created
def get_placement_file_path():
    return os.path.join(app.config("FileStoragePath", default="../"), f"{str(datetime.utcnow()).replace(':', '-')}.jpg")

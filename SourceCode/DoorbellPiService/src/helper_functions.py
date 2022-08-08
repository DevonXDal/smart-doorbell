import os
from datetime import datetime, timezone

from decouple import AutoConfig


# This is used to find a place to put a new image file. Image filenames are decided by the date created
def get_placement_image_filename_and_path(config: AutoConfig):
    return os.path.join(config("FileStoragePath", default="../"), f"{str(datetime.utcnow()).replace(':', '-')}.jpg")


# This is used to find a place to put a new html file. HTML filenames are decided by the date created
def get_placement_html_filename_and_path(config: AutoConfig):
    return os.path.join(config("FileStoragePath", default="../"), f"{str(datetime.utcnow()).replace(':', '-')}.html")


# https://www.geeksforgeeks.org/get-utc-timestamp-in-python/ - mktime gives local time but utc epoch is needed
# Converting datetime to unix time: https://www.geeksforgeeks.org/how-to-convert-datetime-to-unix-timestamp-in-python/
def convert_datetime_to_utc_epoch_int(dt: datetime):
    utc_datetime = dt.replace(tzinfo=timezone.utc)
    return int(utc_datetime.timestamp())

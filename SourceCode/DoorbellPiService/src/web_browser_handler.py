# Details on how to use Selenium for Python/Flask were found at: https://selenium-python.readthedocs.io/getting-started.html

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By

class WebBrowserHandler:
    def __init__(self):
        self.driver = webdriver.Firefox()

import os.path

from decouple import AutoConfig

from arsenic import get_session
from arsenic.browsers import Firefox
from arsenic.services import Geckodriver

from src.app_data import AppData


class WebBrowserHandler:
    def __init__(self, config: AutoConfig):
        self.config = config


    # https://medium.com/analytics-vidhya/asynchronous-web-scraping-101-fetching-multiple-urls-using-arsenic-ec2c2404ecb4 - Code for handling async web requests
    async def handle_video_chat(self, filename_and_path: str, app_data: AppData):
        driver_path = os.path.abspath(self.config('FirefoxWebDriverPath'))
        driver = Geckodriver(binary=driver_path)
        absolute_html_path = os.path.abspath(filename_and_path)

        # https://github.com/HENNGE/arsenic/issues/46 - For Firefox options
        browser = Firefox()

        try:
            async with get_session(driver, browser) as session:
                await session.get('file:///' + absolute_html_path)

                await session.wait_for_element_gone(300, '#disconnect-button')
                self._handle_video_chat_ended()

        except Exception as e:
            print(e)


    def _handle_video_chat_ended(self):
        pass

    def go_to_idle_url(self):
        # self.driver.get(self.config('IdleFirefoxOnPage', default='http://www.blankwebsite.com/'))
        pass

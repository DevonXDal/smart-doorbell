# Setting up the Web Service for the Doorbell

## no_tracking Folder
This folder is used to hold components that are not a part of the project in terms of 
source code, but are necessary in order to function such as the web driver. The contents of
this folder are not tracked. It is placed in the DoorbellPiService folder along with the .env
file. 

### Web Driver
For this project, the web driver needed by Selenium should be placed in the no_tracking folder.
You can find the web driver at https://github.com/mozilla/geckodriver/tree/v0.31.0


## Adding Environment Variables
The project expects the environment file to be called ".env" and be placed in the root
directory of the project. It should be formatted like \
FirstKey=FirstValue \
SecondKey=SecondValue \
ThirdKey=ThirdValue \
\
If there are any spaces in the value, then the value must be enclosed in double quotes (")

### DisplayName="{Name}"
What the display name of the doorbell should show up as on the server and Twilio video chats.
Double quotes allow the display name to contain spaces.
### UseServerPassword={Password}
What password to use for the server in order to acquire the JWT.
### UseServerIpAddress={IPv4 Address}
What IPv4 address to use whether over NAT or the Internet in order to reach the server.
Only this IP address will be able to make requests successfully to the doorbell.
### UseServerPort={Port Number}
What port the server is listening for requests.
### UseDoorbellIpAddress={IPv4 Address}
What IP address the server should send requests to for this doorbell.
### UseDoorbellPort={Port Number}
What port the doorbell will listen on for the server.
### FileStoragePath={Relative or Absolute Path}
What path to use for storing any files (mostly images) created by using the doorbell service
### IsOnRaspberryPi={False/True}
Whether to use the mock watcher (for debugging) or to use the doorbell watcher.
This will crash the system if true but not running on a Raspberry Pi
### UsingGPIOPinForButtonOut={num} - Raspberry Pi Only
The GPIO pin that will send out power when able to another GPIO pin.
### UsingGPIOPinForButtonIn={num} - Raspberry Pi Only
The GPIO pin to detect current from the other GPIO pin on the press of the button. This when 
detecting current will notify the system that the button has been pressed.
### UseUnsecureHTTP={False/True}
Whether to contact the server with https or http.
### FirefoxWebDriverPath={../../no_tracking/geckodriver.???}
Where to find the web driver for Selenium to open Firefox (chromium is more memory hungry...)
The web driver can be placed anywhere, but in this case, to keep everything together, it will 
be placed in the project to keep it close to everything else.
### IdleFirefoxOnPage={https://page.name} (Optional=http://www.blankwebsite.com/)
This will be the page that firefox idles on, this will allow the Raspberry Pi to join the 
call more quickly when it starts. This goes to blankwebsite.com if none is specified
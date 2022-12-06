import requests
import schedule
from requests import ConnectionError

from LocalContainer import LocalContainer
from RemoteContainer import RemoteContainer
from utils.email_utils import send_alert
from utils.print_utils import printg, printr

"""
When using a Remote Container running a awoisoak/photo-shop, in order to trigger a scenario that needs
to be recovered from :
sudo systemctl stop photoshop
sudo kill -9 [PYTHON_PID_PROCESS] 
"""

# Global variable to handle when the monitoring should take any action to report/fix an issue
# If we are currently restarting the server we don't want the monitoring to trigger nested restarts
take_action = True


def monitoring():
    global take_action
    try:
        response = requests.get(uri)
        if response.status_code == 200:
            if not take_action:
                send_alert("Subject: Application is running again!\n Nice script!")
            take_action = True
            printg("Application is running successfully")
        elif take_action:
            printr("Application is down")
            send_alert("Subject: App is down!\nTry restarting the container")
            container.restart_container()
            take_action = False

    except ConnectionError as msg:
        if take_action:
            printr(f"ConnectionError: {msg}")
            send_alert("Subject: Could not connect to container!\nCheck if container is actually running")
            container.restart_host()
            container.restart_container()
            take_action = False


ip = input("Input ip:port of aws ec2 instance or leave it empty to start a container locally\n")
if ip:
    uri = f'http://{ip}'
    container = RemoteContainer(ip)
else:
    uri = "http://localhost:9000/"
    container = LocalContainer()

container.run_container()
print(type(container))

schedule.every(10).seconds.do(monitoring)
try:
    while True:
        schedule.run_pending()
except KeyboardInterrupt:
    container.stop_container("Keyboard Interrupt detection")

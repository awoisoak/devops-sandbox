import requests
import schedule
from requests import ConnectionError

from BaseContainer import BaseContainer
from LocalContainer import LocalContainer
from RemoteContainer import RemoteContainer
from utils.email_utils import send_alert
from utils.print_utils import printg, printr, printy


def monitoring():
    try:
        response = requests.get("http://localhost:9000/")
        if response.status_code == 200:
            printg("Application is running successfully")
        else:
            printr("Application is down")
            send_alert("Subject: App is down!\nTry restarting the container")
            container.restart_container()

    except ConnectionError as msg:
        printr(f"ConnectionError: {msg}")
        send_alert("Subject: Could not connect to container!\nCheck if container is actually running")
        container.restart_container()


url = input("Input ip:port of remote web server or leave it empty to start a container locally")
container: BaseContainer
if url:
    # TODO
    container = RemoteContainer()
else:
    url = "http://localhost:9000/"
    container = LocalContainer()

container.run_container()
printy(container)

schedule.every(6).seconds.do(monitoring)
try:
    while True:
        schedule.run_pending()
except KeyboardInterrupt:
    container.stop_container("Keyboard Interrupt detection")

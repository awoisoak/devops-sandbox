import requests
import schedule
from requests import ConnectionError

from LocalContainer import LocalContainer
from RemoteContainer import RemoteContainer
from utils.email_utils import send_alert
from utils.print_utils import printg, printr


def monitoring():
    try:
        response = requests.get(uri)
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


ip = input("Input ip:port of aws ec2 instance or leave it empty to start a container locally\n")
if ip:
    uri = f'http://{ip}'
    container = RemoteContainer(ip)
else:
    uri = "http://localhost:9000/"
    container = LocalContainer()

container.run_container()
print(type(container))

schedule.every(6).seconds.do(monitoring)
try:
    while True:
        schedule.run_pending()
except KeyboardInterrupt:
    container.stop_container("Keyboard Interrupt detection")

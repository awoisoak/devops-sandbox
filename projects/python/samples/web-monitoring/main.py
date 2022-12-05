from time import sleep

import docker
import requests
import smtplib
import os
import schedule
from docker.errors import APIError
from docker.models.containers import Container
from requests import ConnectionError
from utils.print_utils import printg, printr, printy

# https://support.google.com/accounts/answer/185833?hl=en
DEVOPS_EMAIL_ADDRESS = os.environ.get("DEVOPS_EMAIL_ADDRESS")
DEVOPS_EMAIL_PASSWORD = os.environ.get("DEVOPS_EMAIL_PASSWORD")

docker_client = docker.from_env()


def send_alert(msg):
    """ Send email alert to the specified account"""
    with smtplib.SMTP('smtp.gmail.com', 587) as smtp:
        smtp.starttls()
        smtp.ehlo()
        smtp.login(DEVOPS_EMAIL_ADDRESS, DEVOPS_EMAIL_PASSWORD)
        smtp.sendmail(
            from_addr=DEVOPS_EMAIL_ADDRESS,
            to_addrs=DEVOPS_EMAIL_ADDRESS,
            msg=msg
        )
        print("Email sent")


def run_container():
    """Run a Photo-shop web server container"""
    try:
        return docker_client.containers.run(
            "awoisoak/photo-shop",
            detach=True,
            ports={9000: 9000},
            # network="host"
        )
    except APIError as msg:
        printr(f"APIError: {msg}")
        send_alert(f"Subject: App could not be started!\nTake a look!")


def restart_container():
    printr("restarting container...")
    container.restart()


def stop_container(msg):
    printr("stopping container due to {msg}...")
    container.stop()


def monitoring():
    try:
        response = requests.get("http://localhost:9000/")
        if response.status_code == 200:
            printg("Application is running successfully")
        else:
            printr("Application is down")
            send_alert("Subject: App is down!\nTry restarting the container")
            restart_container()

    except ConnectionError as msg:
        printr(f"ConnectionError: {msg}")
        send_alert("Subject: Could not connect to container!\nCheck if container is actually running")
        restart_container()


container = run_container()
printy(container)
printg("Waiting 5s for photo-shop web server to be available...")
sleep(5)

schedule.every(6).seconds.do(monitoring)
try:
    while True:
        schedule.run_pending()
except KeyboardInterrupt:
    stop_container("Keyboard Interrupt detection")
finally:
    stop_container("Finally detection")

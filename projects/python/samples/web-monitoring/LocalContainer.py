# https://support.google.com/accounts/answer/185833?hl=en
import os
from time import sleep

import docker
from docker.errors import APIError

from BaseContainer import BaseContainer
from utils.email_utils import send_alert
from utils.print_utils import printr, printg

DEVOPS_EMAIL_ADDRESS = os.environ.get("DEVOPS_EMAIL_ADDRESS")
DEVOPS_EMAIL_PASSWORD = os.environ.get("DEVOPS_EMAIL_PASSWORD")


class LocalContainer(BaseContainer):

    def __init__(self):
        self.container = None
        self.docker_client = docker.from_env()

    def restart_host(self):
        # The script is running in host machine so there is no need to restart it
        pass

    def run_container(self):
        super().run_container()
        try:
            self.container = self.docker_client.containers.run(
                "awoisoak/photo-shop",
                detach=True,
                ports={9000: 9000},
                # network="host"
            )
        except APIError as msg:
            printr(f"APIError: {msg}")
            send_alert(f"Subject: App could not be started!\nTake a look!")
        printg("Waiting 5s for photo-shop web server to be available...")
        sleep(5)

    def restart_container(self):
        super().restart_container()
        self.container.restart()

    def stop_container(self, msg):
        super().stop_container(msg)
        self.container.stop()

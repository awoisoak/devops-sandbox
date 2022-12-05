from time import sleep

import requests, docker
from docker.errors import APIError
from requests import HTTPError

from utils.print_utils import printg, printr

docker_client = docker.from_env()

try:
    docker_client.containers.run(
        "awoisoak/photo-shop",
        detach=True,
        ports={9000: 9000},
        # network="host"
    )
except APIError as msg:
    printr(f'APIError: {msg}')

printg("Waiting 5s for photo-shop web server to be available...")
sleep(5)

try:
    response = requests.get("http://localhost:9000/")
    if response.status_code == 200:
        printg("Application is running succesfully")
    else:
        printr("Application is down")
except APIError:
    print("APIError")
except HTTPError:
    print("HTTPError")

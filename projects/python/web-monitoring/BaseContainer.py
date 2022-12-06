from abc import ABC, abstractmethod

from utils.print_utils import printg


class BaseContainer(ABC):

    @abstractmethod
    def restart_host(self):
        """ Restart host where the container is running"""
        printg("restarting host...")

    @abstractmethod
    def run_container(self):
        """Run a Photo-shop web server container"""
        printg("running container...")

    @abstractmethod
    def restart_container(self):
        """Restart container"""
        printg("restarting container...")

    @abstractmethod
    def stop_container(self, msg):
        """Stop container"""
        printg(f"stopping container due to {msg}...")

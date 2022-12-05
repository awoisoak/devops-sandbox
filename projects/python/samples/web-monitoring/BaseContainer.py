from abc import ABC, abstractmethod

from utils.print_utils import printr, printy, printg


class BaseContainer(ABC):
    @abstractmethod
    def run_container(self):
        """Run a Photo-shop web server container"""
        printg("running container...")

    @abstractmethod
    def restart_container(self):
        """Restart container"""
        printy("restarting container...")

    @abstractmethod
    def stop_container(self, msg):
        """Stop container"""
        printr(f"stopping container due to {msg}...")

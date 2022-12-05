from abc import ABC, abstractmethod

from utils.print_utils import printr, printy


class BaseContainer(ABC):
    @abstractmethod
    def run_container(self):
        """Run a Photo-shop web server container"""
        pass

    @abstractmethod
    def restart_container(self):
        """Restart container"""
        printy("restarting container...")
        pass

    @abstractmethod
    def stop_container(self, msg):
        """Stop container"""
        printr(f"stopping container due to {msg}...")
        pass

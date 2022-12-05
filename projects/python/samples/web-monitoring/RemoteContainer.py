import os

import paramiko

from BaseContainer import BaseContainer
from utils.print_utils import printy

AWS_PRIVATE_KEY_FILENAME = os.environ["AWS_PRIVATE_KEY_FILENAME"]


class RemoteContainer(BaseContainer):
    def __init__(self, ip):
        self.ip = ip

    def run_container(self):
        # Remote container is supposed to be run by the user
        pass

    def restart_container(self):
        super().restart_container()
        response = self.ssh_command('docker restart $(docker container ls -q)')
        if len(response) == 0:
            printy("the Photo-shop service is not running, restart it...")
            self.ssh_command('sudo systemctl start photoshop')

    def stop_container(self, msg):
        super().stop_container(msg)
        self.ssh_command('docker stop $(docker container ls -q)')

    def ssh_command(self, command):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname=self.ip, username="ec2-user", key_filename=AWS_PRIVATE_KEY_FILENAME)
        stdin, stdout, stderr = ssh.exec_command(f'{command}')
        output = stdout.readlines()
        printy(output)
        ssh.close()
        return output

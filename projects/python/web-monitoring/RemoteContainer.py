import os
from time import sleep

import boto3
import paramiko
from mypy_boto3_ec2.client import EC2Client

from BaseContainer import BaseContainer
from utils.print_utils import printy, printg, printr

AWS_PRIVATE_KEY_FILENAME = os.environ["AWS_PRIVATE_KEY_FILENAME"]


class RemoteContainer(BaseContainer):

    def __init__(self, ip):
        self.ip = ip

    def restart_host(self):
        super().restart_host()
        self.ssh_command('sudo shutdown -r now')
        printg("Waiting for the host to be restarted and run again...")
        sleep(5)
        ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
        waiter_instance = ec2_client.get_waiter('instance_running')
        waiter_instance.wait(Filters=[
            {
                'Name': 'ip-address',
                'Values': [self.ip]
            }
        ])

    def run_container(self):
        # Remote container is supposed to be run by the user
        pass

    def restart_container(self):
        # In a real scenario we might wanna use AWS CLI to be able to recover from a stop instance
        super().restart_container()
        response = self.ssh_command('docker restart $(docker container ls -q)')
        if response and len(response) == 0:
            printy("the Photo-shop service is not running, restart it...")
            self.ssh_command('sudo systemctl start photoshop')

    def stop_container(self, msg):
        super().stop_container(msg)
        self.ssh_command('docker stop $(docker container ls -q)')

    def ssh_command(self, command):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(hostname=self.ip, username="ec2-user", key_filename=AWS_PRIVATE_KEY_FILENAME)
            stdin, stdout, stderr = ssh.exec_command(f'{command}')
            output = stdout.readlines()
            printy(output)
            ssh.close()
            return output
        except Exception as msg:
            printr(f'SSH Error:{msg}')

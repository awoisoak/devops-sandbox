import boto3
from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.client import EC2Client
from utils import printg

"""
This script will check the state of the current EC2 instances running in the corresponding region
"""
# noinspection PyTypeChecker
ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")


def todo_describe_instance():
    reservations = ec2_client.describe_instances()
    for r in reservations.get("Reservations"):
        instances = r.get("Instances")
        for i in instances:
            print("---------------------")
            print(i.get("InstanceId"))
            print("---------------------")
            print(f'ImageId: {i.get("ImageId")} ')
            print(f'Type: {i.get("InstanceType")} ')
            print(f'KernelId: {i.get("KernelId")} ')
            print(f'KeyName: {i.get("KeyName")} ')
            print(f'LaunchTime: {i.get("LaunchTime")} ')
            print(f'Monitoring: {i.get("Monitoring")} ')
            print(f'PrivateIpAddress: {i.get("PrivateIpAddress")} ')
            print(f'PublicIpAddress: {i.get("PublicIpAddress")} ')
            print(f'PublicDnsName: {i.get("PublicDnsName")} ')
            print(f'SubnetId: {i.get("SubnetId")} ')
            print(f'VpcId: {i.get("VpcId")} ')


def check_state_and_status():
    statuses = ec2_client.describe_instance_status()
    for s in statuses.get("InstanceStatuses"):
        print("---------------------")
        print(s.get("InstanceId"))
        print("---------------------")

        print(f'  Instance State: {s.get("InstanceState").get("Name")}')

        print(f'  Instance Status: {s.get("InstanceStatus").get("Status")}')
        for i in s.get("InstanceStatus").get("Details"):
            print(f'    {i.get("Name")} -> {i.get("Status")}')

        print(f'  System Status: {s.get("SystemStatus").get("Status")}')
        for system_status in s.get("SystemStatus").get("Details"):
            print(f'    {system_status.get("Name")} -> {system_status.get("Status")}')


def execute():
    printg("\nGrabbing EC2 information...")
    todo_describe_instance()
    printg("\nChecking EC2 instances statuses...")
    check_state_and_status()

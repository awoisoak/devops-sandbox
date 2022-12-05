from datetime import datetime, timedelta
from time import sleep

import boto3
import schedule
from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.client import EC2Client

from utils.print_utils import printg, printr, printy

"""
This script will check the state of the current EC2 instances running in the corresponding region
"""
# noinspection PyTypeChecker
ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")


def create_instances(count):
    """ Create {count} instances of EC2 instances that will be used by the script"""
    instances = ec2_resource.create_instances(
        ImageId="ami-0de5311b2a443fb89",
        InstanceType="t2.micro",
        MinCount=count,
        MaxCount=count
    )
    for i in instances:
        print(f'{i.id} created')
    return instances


# TODO ignore terminated instances
# TODO use ec2_resource instead?
def describe_instances():
    """Print information of all instances except the ones with a 'terminated' state"""
    reservations = ec2_client.describe_instances(Filters=[
        {
            'Name': 'instance-state-name',
            'Values': ["pending", "running", "shutting-down", "stopping", "stopped"]
        }
    ])
    for r in reservations.get("Reservations"):
        instances = r.get("Instances")
        for i in instances:
            print("---------------------")
            print(i.get("InstanceId"))
            print("---------------------")
            print(f'ImageId: {i.get("ImageId")} ')
            print(f'Type: {i.get("InstanceType")} ')
            print(f'LaunchTime: {i.get("LaunchTime")} ')
            print(f'PublicIpAddress: {i.get("PublicIpAddress")} ')


def check_state_and_status():
    statuses = ec2_client.describe_instance_status(IncludeAllInstances=True, Filters=[
        {
            'Name': 'instance-state-name',
            'Values': ["pending", "running", "shutting-down", "stopping", "stopped"]
        }
    ])
    for s in statuses.get("InstanceStatuses"):
        print("---------------------")
        print(s.get("InstanceId"))
        print("---------------------")
        state = s.get("InstanceState").get("Name")
        match state:  # Syntax available from Python 3.10
            case "running":
                printg('  Instance State: running')
            case "pending":
                printy('  Instance State: pending')
            case _:
                printr(f'  Instance State: {state}')
        print(f'  Instance Status: {s.get("InstanceStatus").get("Status")}')
        print(f'  System Status: {s.get("SystemStatus").get("Status")}')
    print("##################################")


def execute():
    printg("\nCreate a couple of EC2 instances...")
    create_instances(2)

    printg("\nGrabbing EC2 information...")
    describe_instances()

    printg("\nChecking EC2 instances statuses every 5 seconds and let it run a given time...")
    schedule.every(5).seconds.do(check_state_and_status)

    end_time = datetime.now() + timedelta(seconds=21)
    while True:
        schedule.run_pending()
        if datetime.now() >= end_time:
            break

    printg("\nWake up and continue with the script")
    sleep(1)

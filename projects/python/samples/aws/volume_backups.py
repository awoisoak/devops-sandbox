from time import sleep

import boto3

from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.client import EC2Client
from utils.print_utils import printg, printy

# noinspection PyTypeChecker
ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")
# noinspection PyUnresolvedReferences
account_id = boto3.client('sts').get_caller_identity().get('Account')


def create_snapshots(count=1):
    """ Create a snapshot for all volumes with not deleting/delete/error state"""
    volumes = ec2_resource.volumes.all().filter(
        Filters=[
            {
                'Name': 'status',
                'Values': ['in-use']
            },
        ])
    snapshots = []
    for volume in volumes:
        for c in range(0, count):
            snapshot = volume.create_snapshot()
            snapshots.append(snapshot)
            print(f'{snapshot.id} created from {volume.volume_id} (used by {volume.attachments[0].get("InstanceId")})')
    return snapshots


def create_snapshots_in_volume(volume, count=1):
    """ Create a snapshot for the passed volume"""

    snapshots = []
    for c in range(0, count):
        snapshot = volume.create_snapshot()
        snapshots.append(snapshot)
        print(f'{snapshot.id} created from {volume.volume_id} (used by {volume.attachments[0].get("InstanceId")})')
    return snapshot


def list_snapshots():
    """ List all Snapshots own by our aws account"""
    snapshots = ec2_resource.snapshots.filter(OwnerIds=[account_id])
    for snapshot in snapshots:
        print(f'{snapshot.id} ({snapshot.volume_id})')
    return snapshots


def execute():
    printg("\nCreating Snapshots of current volumes...")
    create_snapshots()
    printg("\nListing all available snapshots...")
    list_snapshots()

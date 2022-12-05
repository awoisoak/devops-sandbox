from time import sleep

import boto3
import ec2
import volume_backups
from utils.print_utils import printg, printy, printr
from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.service_resource import Snapshot

from mypy_boto3_ec2.client import EC2Client

# noinspection PyTypeChecker
ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")


def execute():
    printg("\nCreate an EC2 instance...")
    instance = ec2.create_instances(1)[0]

    printg('\nWait until EC2 instance is in "running" state...')
    while True:
        if ec2_resource.Instance(instance.instance_id).state.get("Name") == "running":
            break

    printg("\nCreate snapshots...")

    snapshot: Snapshot

    for volume in ec2_resource.Instance(instance.instance_id).volumes.all():
        printy(volume)
        snapshot = volume_backups.create_snapshots_in_volume(volume)

    # TODO Get the AZ from here
    # instances = ec2_client.describe_instances(InstanceIds=[instance.instance_id])
    # for i in instances:
    #     printr(i)

    printg("\nWaiting 10s for the created Snapshot to be ready to be used...")
    sleep(10)
    # printg('\nWaiting until the Snapshot is in an "available" state...')
    # while True:
    #     print(snapshot.state)
    #     if snapshot.state == "available":
    #         break

    printg("\nCreate new Volume from the snapshot...")
    # TODO botocore.exceptions.ClientError: An error occurred (IncorrectState) when calling the CreateVolume operation: Snapshot is in invalid state - pending

    new_volume = ec2_resource.create_volume(
        SnapshotId=snapshot.id,
        AvailabilityZone="ap-northeast-1c",
        TagSpecifications=[
            {
                'ResourceType': 'volume',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': 'awo'
                    }
                ]
            }
        ]
    )

    printg('\nWaiting until the volume state become "available"...')

    while True:
        if ec2_resource.Volume(new_volume.volume_id).state == "available":
            ec2_resource.Instance(instance.instance_id).attach_volume(
                VolumeId=new_volume.volume_id,
                Device='/dev/xvdb'
                # TODO find a way to automate this /dev/xdva is used by the current volume in the instance
            )
        break

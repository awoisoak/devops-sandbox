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
    waiter_instance = ec2_client.get_waiter('instance_running')
    waiter_instance.wait(InstanceIds=[instance.instance_id])

    printg("\nCreate snapshots...")

    snapshot: Snapshot

    for volume in ec2_resource.Instance(instance.instance_id).volumes.all():
        snapshot = volume_backups.create_snapshots_in_volume(volume)

    printg("\nWait until Snapshot is in a successful state...")
    waiter_snapshot = ec2_client.get_waiter('snapshot_completed')
    waiter_snapshot.wait()

    printg("\nCreate new Volume from the snapshot...")

    # The volume needs to be created in the same AZ as the instance we are going to attach it to
    az = instance.network_interfaces[0].subnet.availability_zone

    new_volume = ec2_resource.create_volume(
        SnapshotId=snapshot.id,
        AvailabilityZone=az,
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
    print(f'{new_volume} created from {snapshot.id}')

    printg('\nWaiting until the volume state become "available"...')

    waiter_volume = ec2_client.get_waiter('volume_available')
    waiter_volume.wait(VolumeIds=[new_volume.volume_id])
    ec2_resource.Instance(instance.instance_id).attach_volume(
        VolumeId=new_volume.volume_id,
        Device='/dev/xvdb'
        # TODO find a way to automate this /dev/xdva is used by the current volume in the instance
    )

import boto3

from mypy_boto3_ec2.service_resource import EC2ServiceResource

from utils import printg

# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")
# noinspection PyUnresolvedReferences
account_id = boto3.client('sts').get_caller_identity().get('Account')


def create_snapshots():
    """ Create a snapshot for all available volumes"""
    for volume in ec2_resource.volumes.all():
        snapshot = volume.create_snapshot()
        print(f'{snapshot.id} created from {volume.volume_id} (used by {volume.attachments[0].get("InstanceId")})')


def list_snapshots():
    """ List all Snapshots own by our aws account"""
    for snapshot in ec2_resource.snapshots.filter(OwnerIds=[account_id]):
        print(f'{snapshot.id} ({snapshot.volume_id})')


def remove_snapshots():
    """ Remove all Snapshots own by our aws account"""
    # While filtering, instead of grabbing our account id we can use the self keyword as below
    for snapshot in ec2_resource.snapshots.filter(OwnerIds=["self"]):
        response = snapshot.delete()
        print(f'Removing {snapshot.id}... response:{response.get("ResponseMetadata").get("HTTPStatusCode")}')


def execute():
    printg("\nCreating Snapshots of current volumes...")
    create_snapshots()
    printg("\nListing all available volumes...")
    list_snapshots()
    printg("\nRemoving all snapshots...")
    remove_snapshots()

import boto3
from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.client import EC2Client

# noinspection PyTypeChecker
from utils.print_utils import printg

ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")


def clean_all_resources():
    def delete_snapshots():
        """ Remove all Snapshots own by our aws account"""
        # While filtering, instead of grabbing our account id we can use the self keyword as below
        for snapshot in ec2_resource.snapshots.filter(OwnerIds=["self"]):
            response = snapshot.delete()
            print(f'Removing {snapshot.id}... response:{response.get("ResponseMetadata").get("HTTPStatusCode")}')

    def terminate_instances():
        """ Terminate all instances available in the region
        By default, Amazon EC2 deletes all EBS volumes that were attached when the instance launched.
        Volumes attached after instance launch continue running.
        """
        reservations = ec2_client.describe_instances(
            Filters=[
                {
                    'Name': 'instance-state-name',
                    'Values': ['pending', 'running', 'shutting-down', 'stopping', 'stopped']
                },
            ]
        )

        for reservation in reservations.get("Reservations"):
            instances = reservation.get("Instances")
            ids = [i.get("InstanceId") for i in instances]
            response = ec2_client.terminate_instances(InstanceIds=ids)

            for r in response.get("TerminatingInstances"):
                print(f' Terminating {r.get("InstanceId")} '
                      f'{r.get("PreviousState").get("Name")} > {r.get("CurrentState").get("Name")}')

    #TODO Handle edge casebotocore.exceptions.ClientError: An error occurred (VolumeInUse) when calling the DeleteVolume operation: Volume vol-03436d5a2cacf0f66 is currently attached to i-0e3970b02966cfa79
    def delete_volumes():
        for volume in ec2_resource.volumes.all():
            response = volume.delete()
            print(f' Deleting {volume.volume_id}')

    printg("\nDelete Snapshots...")
    delete_snapshots()
    printg("\nTerminate Instances...")
    terminate_instances()
    printg("\nDeleting Volumes...")
    delete_volumes()

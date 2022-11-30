import boto3
from mypy_boto3_ec2.service_resource import EC2ServiceResource
from mypy_boto3_ec2.client import EC2Client

from utils import printg

"""
This script will create VPCs with subnets, list them and finally destroy them.
"""

# noinspection PyTypeChecker
ec2_client: EC2Client = boto3.client('ec2', region_name="ap-northeast-1")
# noinspection PyTypeChecker
ec2_resource: EC2ServiceResource = boto3.resource('ec2', region_name="ap-northeast-1")

VPC_NAME = "My Python VPC"


def create_vpc_with_client():
    """Create VPC with client"""
    response = ec2_client.create_vpc(CidrBlock="10.0.0.0/16")
    vpc_id = response.get("Vpc").get("VpcId")
    ec2_client.create_subnet(CidrBlock="10.0.1.0/24", VpcId=vpc_id)
    ec2_client.create_subnet(CidrBlock="10.0.2.0/24", VpcId=vpc_id)
    ec2_client.create_tags(
        Tags=[{
            'Key': 'Name',
            'Value': VPC_NAME
        }],
        Resources=[
            vpc_id
        ])


def create_vpc_with_resource():
    """Create VPC with resource"""
    new_vpc = ec2_resource.create_vpc(CidrBlock="10.1.0.0/16")
    new_vpc.create_subnet(CidrBlock="10.1.1.0/24")
    new_vpc.create_subnet(CidrBlock="10.1.2.0/24")
    new_vpc.create_tags(
        Tags=[{
            'Key': 'Name',
            'Value': VPC_NAME
        }]
    )


def get_vpcs():
    """List current VPCs (created by this program or not) in the specified region returning the VPC ids"""
    vpcs = ec2_client.describe_vpcs()
    vpc_ids = []
    for vpc in vpcs.get("Vpcs"):
        print(f'VPC Id: {vpc.get("VpcId")}, State: {vpc.get("State")}, Tags:{vpc.get("Tags")}')
        if vpc.get("Tags") and vpc.get("Tags")[0]["Value"] == VPC_NAME:
            vpc_ids.append(vpc.get("VpcId"))
    return vpc_ids


def remove_vpcs(vpc_ids):
    """Remove subnets associated to the passed vpcs before removing them completely """
    for vpc_id in vpc_ids:
        subnets = ec2_client.describe_subnets(
            Filters=[
                {
                    'Name': 'vpc-id',
                    'Values': [
                        vpc_id
                    ]
                }
            ]
        )
        for subnet in subnets.get("Subnets"):
            subnet_id = subnet.get("SubnetId")
            response = ec2_client.delete_subnet(SubnetId=subnet_id)
            print(f'Removing {subnet_id}... response:{response.get("ResponseMetadata")["HTTPStatusCode"]}')

        response = ec2_client.delete_vpc(VpcId=vpc_id)
        print(f'Removing {vpc_id}... response:{response.get("ResponseMetadata")["HTTPStatusCode"]}')


def execute():
    printg("\nCreating 'My Python VPCs' and listing all of them...")
    create_vpc_with_client()
    create_vpc_with_resource()
    vpc_ids = get_vpcs()
    printg("\nRemoving 'My Python VPCs'...")
    remove_vpcs(vpc_ids)

import ec2
import volume_backups
import vpc

"""
This app interacts with the AWS account.
In this case the next env variables are set:
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION

Boto3 API documentation for EC2
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html

Clients are low level APIs
Resources are wrapper over clients that are friendlier (specially returning objects in requests).
Resources do not have access to all APIs that clients provide though.


"""

vpc.execute()
ec2.execute()
volume_backups.execute()

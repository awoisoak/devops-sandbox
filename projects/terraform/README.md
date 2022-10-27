To connect to EC2 instance: 

`ssh -v -i "[PRIVATE_KEY]" ec2-user@[PUBLIC_DNS]`

ex)

`    ssh -v -i "/Users/awo/.ssh/aws_id_rsa" ec2-user@ec2-35-79-199-36.ap-north`


Debug issues with the user data by checking /var/log/user-data.log in EC2 instance.
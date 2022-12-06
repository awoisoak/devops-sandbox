The Terraform files will deploy the next infrastructure

<img width="1380" alt="aws" src="https://user-images.githubusercontent.com/11469990/199511219-b2c25415-cd76-46a9-9346-a7868a51f17f.png">



- The VPC contains 3 subnets: 1 public and 2 privates.
- The web server is located in the public one to be accessed by users.
- The database is located in one of the private subnets 
- RDS needs a 'DB subnet group' which requires at least 2 subnets in different Availability Zones to create a new standby if needed in the future [(+info)](https://aws.amazon.com/rds/faqs/)
- The web server only accepts http and ssh connections from outside (ssh should be limited to the admin ip in production)
- The database only accepts connections in the port 3306 from the EC2 instance


To see the exact changes that Terraform will apply: 
```console
terraform plan -var-file="secrets.tfvars"
```
To trigger the infraestructure setup:
```console
terraform apply -var-file="secrets.tfvars"
```
Once you are done don't forget to destroy all resources to avoid AWS charges!
```console
terraform destroy -var-file="secrets.tfvars"
```

In order to initialize the DB with some data we will have to do it through a SSH tunnel (SSH port forwarding) through the EC2:

```console
sh -i "$PRIVATE_KEY_PATH" -N -L 6666:$DB_ADDRESS:3306 ec2-user@$WEB_ADDRESS
```

With the tunnel above setup, all connections againt our localhost:6666 will be forward to the 3306 port of the RDS allowing us to populate the DB:         

```console
mysql -u $DB_USER -p$DB_PASSWORD -h 127.0.0.1 -P 6666 < scripts/setup_db.sql
```

Assuming Terraform was setup with the corresponding AWS account the infrastructure can be deployed with the next command:
```console
terraform apply -var-file="secrets.tfvars"
```
All components are using Free Tier components but make sure you destroy them once you stop working with them to avoid being charged:
```console
terraform destroy -var-file="secrets.tfvars"
```

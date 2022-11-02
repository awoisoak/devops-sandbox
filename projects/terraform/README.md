[WIP]

This Terraform project will deploy the next infraestructure:

TODO

- The VPC contains 3 subnets: 1 public and 2 privates.
- The web server is located in the public one to be accessed by users.
- The database is located in one of the private subnets 
(RDS needs a 'DB subnet group' which requires at least 2 subnets in different AZ (+info: https://aws.amazon.com/rds/faqs/))

- The web server only accepts http and ssh connections from outside (ssh should be limited to the admin ip in production)
- The database only accepts connections in the port 3306

Since the RDS instance is not accesible outside the VPC for security reasons the conf file setup a SSH Port Forwarding to connect to the RDS through the EC2.

 `             ssh -i "$PRIVATE_KEY_PATH" -N -L 6666:$DB_ADDRESS:3306 ec2-user@$WEB_ADDRESS
              $SQL_CLIENT_PATH -u $DB_USER -p$DB_PASSWORD -h 127.0.0.1 -P 6666 < scripts/setup_db.sql`

 The Docker container already running the web-server will have to be restarted to be able to connect to the DB:
            `ssh -v -i "[PRIVATE_KEY]" ec2-user@[PUBLIC_DNS]`
            `docker container stop $(docker container list -qa)` 
 The docker container is running on a service so it will be restarted automatically and this time it should be able to connect succesfully to the DB           




To connect to EC2 instance: 

`ssh -v -i "[PRIVATE_KEY]" ec2-user@[PUBLIC_DNS]`




Debug issues with the user data by checking /var/log/user-data.log in EC2 instance.
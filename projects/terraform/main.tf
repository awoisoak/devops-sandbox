###############
# Security
###############

# Upload public key to aws from a previously manually generated key par
resource "aws_key_pair" "photoshop_key" {
  key_name   = "photoshop_key"
  public_key = file("/Users/awo/.ssh/aws_id_rsa.pub") #TODO move to vars
}


###############
# Networking
###############

# Data source to have access to the AZ within the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create our own VPC in Tokyo
resource "aws_vpc" "tokyo_vpc" {

  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "tokyo_vpc"
  }
}

# Public subnet for the EC2 instance in the first AZ available
resource "aws_subnet" "tokyo_public_subnet_1" {
  vpc_id            = aws_vpc.tokyo_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "tokyo_public_subnet_1"
  }
}

# RDS needs a 'DB subnet group' which requires at least 2 subnets in different AZ 
# (+info: https://aws.amazon.com/rds/faqs/)
resource "aws_db_subnet_group" "db_subnet_group" {
  description = "DB subnet group required by RDS"
  subnet_ids  = [aws_subnet.tokyo_private_subnet_1.id, aws_subnet.tokyo_private_subnet_2.id]
  tags = {
    "Name" = "db_subnet_group"
  }
}

# Private subnet for the RDS instance in the first AZ available
resource "aws_subnet" "tokyo_private_subnet_1" {
  vpc_id            = aws_vpc.tokyo_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "tokyo_private_subnet_1"
  }
}

# Private subnet for the RDS instance in the second AZ available
resource "aws_subnet" "tokyo_private_subnet_2" {
  vpc_id            = aws_vpc.tokyo_vpc.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name" = "tokyo_private_subnet_2"
  }
}

# Create an internet gateway for our VPC
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.tokyo_vpc.id
  tags = {
    "Name" = "gateway"
  }
}

# Create a public route table that gives access to the internet through the gateway we just created
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tokyo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    "Name" = "public_route_table"
  }
}

# Associate the public route table to the public subnet 
resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.tokyo_public_subnet_1.id
}

# Create a private route table 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.tokyo_vpc.id
  # Since this is a going to be a private subnet we won't add any route
  tags = {
    "Name" = "private_route_table"
  }
}

# Associate the private route table to the private subnet  1
resource "aws_route_table_association" "private_association_1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.tokyo_private_subnet_1.id
}

# Associate the private route table to the private subnet  2
resource "aws_route_table_association" "private_association_2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.tokyo_private_subnet_2.id
}

# SG for the web server
resource "aws_security_group" "sg_web_server" {
  name        = "sg_web_server"
  description = "Security group to be used by the photo-shop web server"
  # We need to specify our VPC, otherwise by default will be applied to the region's default VPC
  vpc_id = aws_vpc.tokyo_vpc.id

  ingress {
    description = "SSH from everywhere (just for dev purposes)"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "HTTP access from everywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  egress {
    description = "Allow any output traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }

}

# SG for the Database 
resource "aws_security_group" "sg_database" {
  name        = "sg_database"
  description = "Security group to be used by the Database"
  # We need to specify our VPC, otherwise by default will be applied to the region's default VPC
  vpc_id = aws_vpc.tokyo_vpc.id

  # Only the EC2 should be able to connect to the DB
  ingress {
    description     = "Allow Mysql traffic only from web server"
    security_groups = [aws_security_group.sg_web_server.id]
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
  }

  #TODO  Temporarily allow ssh connection for debugging purposes
  ingress {
    description = "[TEMP] Allow mysql traffic from all vpc"
    cidr_blocks = [aws_vpc.tokyo_vpc.cidr_block]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  }
}

###############
# Services
###############
resource "aws_instance" "web_server" {
  ami                    = "ami-0de5311b2a443fb89" #Amazon Linux image based in CentOS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.tokyo_public_subnet_1.id
  key_name               = aws_key_pair.photoshop_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_web_server.id]
  depends_on             = [aws_db_instance.database]

  #TODO remove the nonsensitive, just for debugging purposes
  user_data = templatefile("scripts/setup_web_server.sh", {
    "db_address" = "${aws_db_instance.database.address}"
  })

  # TODO this should be done outside terraform Setup a SSH Port Forwarding to be able to connec to RDS trough the EC2
  # TODO will not work because it needs the AWS_INSTANCE PUBLIC IP but creates a circular dependency wit aws_eip
  # TODO try to do it at the end of terraform lifecycle or directly outside
  # provisioner "local-exec" {

  #   interpreter = ["/bin/bash", "-c"]
  #   command     = <<-EOT
  #             ssh -i "$PRIVATE_KEY_PATH" -N -L 6666:$DB_ADDRESS:3306 ec2-user@$WEB_ADDRESS&

  #             echo "CREATE USER 'user'@'10.0.1.%' IDENTIFIED BY 'password';
  #               GRANT ALL PRIVILEGES ON *.* TO 'user'@'10.0.1.%';
  #               FLUSH PRIVILEGES;
  #               CREATE DATABASE photosdb;
  #               USE photosdb;
  #               CREATE TABLE photos (id mediumint(8) unsigned NOT NULL auto_increment,name varchar(255) default NULL,price varchar(255) default NULL, image_url varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
  #               INSERT INTO photos (name,price,image_url) VALUES ("Tohoku","100","Japan-1.jpg"),("Osaka","200","Japan-2.jpg"),("Senso-ji","300","Japan-3.jpg"),("Shibuya","50","Japan-4.jpg"),("Fuji reflection","90","Japan-5.jpg"),("Fuji sunrise","20","Japan-6.jpg"),("Kyoto","80","Japan-7.jpg"),("Hiroshima","150","Japan-8.jpg"),("Miyajima","150","Japan-9.jpg"),("Gozanoishi Shrine","150","Japan-10.jpg"),("Cold mountains","150","Japan-11.jpg"),("Warm mountains","150","Japan-12.jpg");" | sudo tee /tmp/setup_db.sql

  #             "$SQL_CLIENT_PATH" -u $DB_USER -p$DB_PASSWORD -h 127.0.0.1 -P 6666 < /tmp/setup_db.sql
  #   EOT
  #   environment = {
  #     PRIVATE_KEY_PATH = "/Users/awo/.ssh/aws_id_rsa.pub"           #TODO move out to variables
  #     SQL_CLIENT_PATH  = "/opt/homebrew/opt/mysql-client/bin/mysql" #TODO move out to variables
  #     DB_ADDRESS       = "${aws_db_instance.database.address}"
  #     WEB_ADDRESS      = "${aws_eip.web_server_ip.public_ip}"
  #     DB_USER          = "${var.db_username}"
  #     DB_PASSWORD      = "${var.db_password}"
  #   }

  # }
}

resource "aws_db_instance" "database" {
  # The allocated storage in gigabytes
  allocated_storage = 20

  # The database engine to use
  engine = "mariadb"

  # The version of the database engine
  engine_version = 10.6

  # The instance type of the RDS instance
  instance_class = "db.t3.micro"

  # #  The name of the database to create when the DB instance is created
  # db_name = "photosdb" #already done by the sql script

  # Username for the master DB user
  username = var.db_username

  # Password for the master DB user.
  password = var.db_password

  # Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group.
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id

  # List of VPC security groups to associate.
  vpc_security_group_ids = [aws_security_group.sg_database.id]

  # Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created.
  skip_final_snapshot = true

  # Specifies whether any database modifications are applied immediately, or during the next maintenance window.allow_major_version_upgrade
  # Using apply_immediately can result in a brief downtime as the server reboots.
  apply_immediately = true
}

# Create an Elastic IP to make sure the webserver gets a fixed ip
resource "aws_eip" "web_server_ip" {
  vpc      = true
  instance = aws_instance.web_server.id #If not specified web_server won't get this ip. web_server won't need the associate_public_ip_address

  # Print public ip generated and approximated cost of current architecture
  provisioner "local-exec" {
    command = <<EOT
        echo ${self.public_ip} ;
        terraform state pull | curl -s -X POST -H 'Content-Type: application/json' -d @- https://cost.modules.tf/
    EOT
  }
}

###############
# Services
###############
resource "aws_instance" "web_server" {
  ami                    = "ami-0de5311b2a443fb89" #Amazon Linux image based in CentOS
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.photoshop_key.key_name
  user_data              = file("./setup_server.sh")
  vpc_security_group_ids = [aws_security_group.sg_web_server.id]
}

###############
# Security
###############

# Upload public key to aws from a previously manually generated key par
resource "aws_key_pair" "photoshop_key" {
  key_name   = "photoshop_key"
  public_key = file("/Users/awo/.ssh/aws_id_rsa.pub")
}


###############
# Networking
###############

# Since we are not currently creating our own VPC, this data source allow us to reference
# the default VPC created by AWS (172.31.0.0/16)
data "aws_vpc" "default" {
  default = true
}

# SG for the web server (by default applied to the region's default VPC)
resource "aws_security_group" "sg_web_server" {
  name        = "sg_web_server"
  description = "Security group to be used by photo-shop web server"

  ingress {
    description = "SSH from everywhere (just for dev purposes)"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "HTTP access"
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

# Create an Elastic IP to make sure the webserver gets a fixed ip
resource "aws_eip" "web_server_ip" {
  vpc      = true
  instance = aws_instance.web_server.id

  # Print public ip generated and approximated cost of current architecture
  provisioner "local-exec" {
    command = <<EOT
        echo ${self.public_ip} ;
        terraform state pull | curl -s -X POST -H 'Content-Type: application/json' -d @- https://cost.modules.tf/
    EOT
  }
}
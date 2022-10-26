resource "aws_instance" "cerberus" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.cerberus-key.key_name
  user_data     = file("./install-nginx.sh")
  # Alternative way of using user_data 
  # user_data     = <<-EOF
  #                 #!/bin/bash
  #                 sudo yum update -y
  #                 sudo yum install nginx -y
  #                 sudo systemctl start nginx
  #                 EOF
}

resource "aws_key_pair" "cerberus-key" {
  key_name   = "cerberus"
  public_key = file(".ssh/cerberus.pub")

}
#Elastic IP so make sure the EC2 instance got a fixed ip
resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.cerberus.id

  provisioner "local-exec" {
    command = "echo ${self.public_dns} >> /root/cerberus_public_dns.txt"
  }
}
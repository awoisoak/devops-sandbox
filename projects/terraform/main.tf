
resource "aws_instance" "web_server" {
  ami           = "ami-0de5311b2a443fb89"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.photoshop_key.key_name
  #TODO user data to install and run photoshop docker image
}

# Upload public key to aws from a previously manually generated key par
resource "aws_key_pair" "photoshop_key" {
  key_name   = "photoshop_key"
  public_key = file("/Users/awo/.ssh/aws_id_rsa.pub")
}

# Create an Elastic IP to make sure the webserver gets a fixed ip
resource "aws_eip" "web_server_ip" {
  vpc      = true
  instance = aws_instance.web_server.id

  # Print public DNS generated and approximated cost of architecture
  provisioner "local-exec" {
    command = <<EOT
        echo ${self.public_dns} ;
        terraform state pull | curl -s -X POST -H 'Content-Type: application/json' -d @- https://cost.modules.tf/
    EOT
  }
}
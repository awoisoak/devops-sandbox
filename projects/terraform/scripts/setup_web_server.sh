#! /bin/bash

echo "#### Update system and install dependencies "
sudo yum update -y
sudo yum install docker -y
sudo yum install mysql -y

echo "#### Setup Docker service" 
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo su - ec2-user

echo "#### Creating service to run photo-shop web server" 
sudo echo "[Unit]
Description=Run Photo-shop service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=ec2-user
ExecStart=/usr/bin/docker run -t -p 80:9000 -e DATABASE_URL=${db_address} awoisoak/photo-shop

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/photoshop.service

systemctl start photoshop
systemctl enable photoshop


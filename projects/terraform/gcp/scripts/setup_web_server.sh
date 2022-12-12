#! /bin/bash

echo "#### Update system and install dependencies "
sudo yum update -y
sudo yum install docker -y
sudo yum install mysql -y

echo "#### Setup Docker service" 
# CentOS 7 installs Docker 1.13.1 which doesn't include docker group but dockerroot 
# https://forums.docker.com/t/dockerroot-vs-docker-group/50105/3
echo "{
    \"group\":\"dockerroot\"
}" | sudo tee /etc/docker/daemon.json

# Create a new docker user and added to the dockerroot group
sudo useradd docker
sudo usermod -a -G dockerroot docker

# Start and enable docker service
sudo systemctl start docker
sudo systemctl enable docker


echo "#### Creating service to run photo-shop web server" 
echo "[Unit]
Description=Run Photo-shop service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=docker
ExecStart=/usr/bin/docker run -t -p 80:9000 -e DATABASE_URL=${db_address} awoisoak/photo-shop
[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/photoshop.service

sudo systemctl start photoshop
sudo systemctl enable photoshop
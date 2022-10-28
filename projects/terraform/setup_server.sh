#! /bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
sudo su - ec2-user

sudo echo "[Unit]
Description=Run Photo-shop service
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=1
User=ec2-user
ExecStart=/usr/bin/docker run -t -p 80:9000 awoisoak/photo-shop

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/photoshop.service
systemctl start photoshop
systemctl enable photoshop
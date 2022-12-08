#!/bin/bash
sudo yum update -y
sudo yum install nginx -y
sudo systemctl start nginx
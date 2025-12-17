#!/bin/bash
yum update -y
yum install -y nginx

# For Amazon Linux 2, install docker using amazon-linux-extras
sudo yum install docker -y

# Install pip (if not already installed)
yum install -y python3-pip

# Install docker-compose
sudo mkdir -p /usr/local/libexec/docker/cli-plugins/
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/libexec/docker/cli-plugins/docker-compose
sudo ln -s /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
docker-compose version


# Start and enable services
systemctl start docker
systemctl enable docker
systemctl start nginx
systemctl enable nginx

# Add ec2-user to docker group
usermod -aG docker ec2-user

#!/bin/bash

apt install curl gnupg2 ca-certificates lsb-release -y
echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
apt update
apt install nginx

systemctl enable nginx
systemctl start nginx    
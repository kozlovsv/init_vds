#!/bin/bash

apt update && sudo apt upgrade -y

apt -y -q install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    wget \
    mc \
    htop

# Uninstall old versions
apt remove docker docker-engine docker.io containerd runc

# SET UP THE REPOSITORY
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update

# INSTALL Docker
apt install docker-ce docker-ce-cli containerd.io


systemctl start docker
systemctl enable docker

#Init docker SWARM mode
#docker swarm init

#Install docker composer and python
curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache

#DOCER REDIS config
printf '#!/bin/sh -e\nsysctl vm.overcommit_memory=1\nsysctl -w net.core.somaxconn=65535\necho madvise > /sys/kernel/mm/transparent_hugepage/enabled\nexit 0' > /etc/rc.local
chmod +x /etc/rc.local
systemctl restart rc-local


#!/bin/bash

yum update -y 

# Uninstall old versions
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine \
    docker-ce \
    docker-ce-cli \
    containerd.io

# SET UP THE REPOSITORY
yum install -y yum-utils \
      device-mapper-persistent-data \
      lvm2

yum-config-manager \
      --add-repo \
      https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io


systemctl start docker
systemctl enable docker

#Init docker SWARM mode
#docker swarm init

#Install docker composer and python
yum install -y epel-release
yum install -y python36 pip3
pip3 install docker-compose

yum upgrade -y python*


yum clean all 
rm -rf /root/.cache

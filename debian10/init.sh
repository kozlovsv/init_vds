#!/bin/bash

apt update && sudo apt upgrade -y

apt -y -q install \
    wget \
    curl \
    mc \
    htop
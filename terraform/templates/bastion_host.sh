#!/bin/bash
sudo apt update
sudo apt install -y python3-pip
pip install ansible
export PATH=/home/ubuntu/.local/bin:$PATH

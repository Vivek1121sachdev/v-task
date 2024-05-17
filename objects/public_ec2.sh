#! /bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install awscli -y
sudo aws s3 ls s3://v-task-objects > objects.txt
sudo aws s3 cp s3://v-task-objects/key-pair.pem .
sudo chmod 0400 key-pair.pem


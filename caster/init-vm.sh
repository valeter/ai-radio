#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
# https://yandex.cloud/ru/docs/compute/operations/vm-connect/auth-inside-vm#auth-inside-vm
yc iam create-token | sudo docker login --username iam --password-stdin cr.yandex
sudo docker pull cr.yandex/crpeb8o2m5imlu3ivr97/ai-radio-caster:v1
sudo docker run -d --name ai-radio-caster-instance -p 80:80 cr.yandex/crpeb8o2m5imlu3ivr97/ai-radio-caster:v1
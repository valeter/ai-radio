#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
# https://yandex.cloud/ru/docs/compute/operations/vm-connect/auth-inside-vm#auth-inside-vm
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
source "/home/valter/.bashrc"
yc config profile create my-robot-profile
yc config set cloud-id b1gqm3pcf75g7hjrn0l9
yc config set folder-id b1g2inpl68al98r9ock7

yc iam create-token | sudo docker login --username iam --password-stdin cr.yandex
sudo docker pull cr.yandex/crpcfge9mu4jrh3rg68j/ai-radio-caster:v1
sudo docker run -d --name ai-radio-caster-instance -p 443:443 cr.yandex/crpcfge9mu4jrh3rg68j/ai-radio-caster:v1

sudo ufw allow 443/tcp
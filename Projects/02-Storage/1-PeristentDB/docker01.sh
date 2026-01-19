#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
usermod -aG docker vagrant
docker volume create mysql-vol
docker volume create postgres-vol
docker run --name mysql -e MYSQL_ROOT_PASSWORD=test -d -p 3306:3306 -v mysql-vol:/var/lib/mysql mysql:lts
docker run --name postgres -e POSTGRES_PASSWORD=test -d -p 5432:5432 -v postgres-vol:/var/lib/postgresql postgres:latest 

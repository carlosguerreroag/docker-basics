#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    jq \
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
docker volume create app-config
docker run --rm -v app-config:/config -v /vagrant:/source busybox cp /source/config.yaml /config/config.yaml
docker build --build-arg APP_PORT=19000 -t api /vagrant/.
export APP_PORT=9000
export HOST_PORT=3000
docker run -d --name api -e APP_PORT="$APP_PORT" -e VAR3="Hi from docker run -e!" --env-file /vagrant/.env -p "$HOST_PORT":"$APP_PORT" -v app-config:/config api

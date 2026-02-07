#!/usr/bin/env bash
docker swarm init --advertise-addr 192.168.56.16 
cat /vagrant/mysql-creds | grep root | awk '{print $2}' FS=":" | docker secret create mysql_root_password -
cat /vagrant/mysql-creds | grep ftpuser | awk '{print $2}' FS=":" | docker secret create mysql_user_password -
docker stack deploy -c /vagrant/docker-compose.yaml storage-system

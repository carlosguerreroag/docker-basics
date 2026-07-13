#!/usr/bin/env bash

vm_hostname=$(hostname)
vm_ip=$(ip -br -4 addr show | awk '/192\.168\.56\./ {print $3; exit}' | cut -d/ -f1)

case "$vm_hostname" in
    "n01")
        docker swarm init --advertise-addr "$vm_ip"
        docker swarm join-token worker -q > /vagrant/swarm_token.txt
        docker service create --replicas 3 alpine ping 8.8.8.8
    ;;

    *)
        while [ ! -f /vagrant/swarm_token.txt ]; do 
            echo "Waiting for token to be available..."
            sleep 2; 
        done 
        echo "Token available, joining Swarm cluster as worker..."
        swarm_token=$(cat /vagrant/swarm_token.txt)
        n01_ip=$(host n01 | awk '/192\.168\.56\./ {print $4; exit}' | cut -d/ -f1)
        docker swarm join --token "$swarm_token" "$n01_ip":2377
    ;;
esac
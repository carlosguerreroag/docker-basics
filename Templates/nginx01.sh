#!/usr/bin/env bash
apt update && apt upgrade -y
apt install wget curl nginx -y
cat <<EOF > /etc/nginx/sites-available/vproapp
upstream vproapp {
    server 192.168.56.12:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOF
rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
systemctl restart nginx
chmod +x /vagrant/zabbix-*
bash /vagrant/zabbix-agent-ubuntu.sh

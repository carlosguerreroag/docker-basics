#!/bin/bash
cd /vagrant
git clone -b local https://github.com/hkhcoder/vprofile-project.git
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_7.4+ubuntu22.04_all.deb
rm $_
apt update
apt install mysql-server zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y

sudo mysql <<EOF
create database zabbix character set utf8mb4 collate utf8mb4_bin;
create user 'zabbix'@'localhost' identified with mysql_native_password by 'zabbix';
grant all privileges on zabbix.* to 'zabbix'@'localhost';
set global log_bin_trust_function_creators = 1;
flush privileges;
EOF

zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -pzabbix zabbix

sudo mysql <<EOF
set global log_bin_trust_function_creators = 0;
EOF

#sed -i 's/^# DBPassword=.*/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/^#\? *DBPassword=.*/DBPassword=zabbix/' /etc/zabbix/zabbix_server.conf
sed -i 's/^[[:space:]]*#\?[[:space:]]*listen[[:space:]]\+8080;/listen 80;/' /etc/zabbix/nginx.conf
sed -i 's/^[[:space:]]*#\?[[:space:]]*server_name[[:space:]]\+example\.com;/server_name zmonitor01-vagrant.local;/' /etc/zabbix/nginx.conf
sed -i '/listen \[::\]:80 default_server;/ s/^/# /' /etc/nginx/sites-enabled/default
sed -i '/listen 80 default_server;/ s/^/# /' /etc/nginx/sites-enabled/default

systemctl restart zabbix-server zabbix-agent nginx php8.1-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.1-fpm 

ip=$(ip addr | grep 192 | awk '{print $2}' | awk '{print $1}' FS='/')
echo -e "[!] All GOOD, visit Zabbix on: $ip"

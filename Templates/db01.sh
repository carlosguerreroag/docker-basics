#!/usr/bin/env bash
dnf update -y
dnf install epel-release -y
dnf install git wget curl mariadb-server -y
dnf install expect -y
systemctl start mariadb
systemctl enable mariadb
sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
EOF
chmod +x /vagrant/mysql_expect_script.exp
/vagrant/mysql_expect_script.exp
sudo mysql <<EOF
create database accounts;
grant all privileges on accounts.* to 'admin'@'localhost' identified by 'admin123';
grant all privileges on accounts.* to 'admin'@'%' identified by 'admin123';
FLUSH PRIVILEGES;
EOF
sudo mysql accounts < /vagrant/vprofile-project/src/main/resources/db_backup.sql
systemctl restart mariadb
systemctl start firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=10050/tcp --permanent
firewall-cmd --reload
systemctl restart mariadb
chmod +x /vagrant/zabbix-agent-centos9.sh
bash /vagrant/zabbix-agent-centos9.sh

#!/usr/bin/env bash
dnf update -y
dnf install epel-release -y
dnf install wget curl -y
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server
echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
rabbitmqctl set_permissions -p / test ".*" ".*" ".*"
systemctl restart rabbitmq-server
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --add-port=5672/tcp
firewall-cmd --runtime-to-permanent
firewall-cmd --add-port=10050/tcp
firewall-cmd --runtime-to-permanent
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
chmod +x /vagrant/zabbix-agent-centos9.sh
bash $_

#!/usr/bin env bash

awk -v newline='excludepkgs=zabbix*' '$0=="[epel]"{print;in_block=1;next} /^\[/ && in_block{print newline; in_block=0} {print} END{if(in_block) print newline}' /etc/yum.repos.d/epel.repo > /etc/yum.repos.d/epel.repo.tmp && mv /etc/yum.repos.d/epel.repo.tmp /etc/yum.repos.d/epel.repo
rpm -Uvh https://repo.zabbix.com/zabbix/7.4/release/centos/9/noarch/zabbix-release-latest-7.4.el9.noarch.rpm
dnf clean all
dnf install zabbix-agent -y
rm /etc/zabbix/zabbix_agentd.conf
cp /vagrant/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent
systemctl enable zabbix-agent
chmod +x /vagrant/zabbix-agent-register.sh 
bash /vagrant/zabbix-agent-register.sh

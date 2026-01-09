#!/usr/bin/env/ bash
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu22.04_all.deb
dpkg -i zabbix-release_latest_7.4+ubuntu22.04_all.deb
rm $_
apt update
apt install zabbix-agent -y
rm /etc/zabbix/zabbix_agentd.conf
cp /vagrant/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
systemctl restart zabbix-agent
systemctl enable zabbix-agent 
chmod +x /vagrant/zabbix-agent-register.sh
bash /vagrant/zabbix-agent-register.sh

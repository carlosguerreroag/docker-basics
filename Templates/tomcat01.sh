#!/usr/bin/env bash

dnf update -y
dnf install epel-release -y
dnf install java-17-openjdk java-17-openjdk-devel -y
dnf install git wget unzip -y
wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.26/bin/apache-tomcat-10.1.26.tar.gz -O /tmp/apache-tomcat.tar.gz
cd /tmp
tar -xzvf apache-tomcat.tar.gz
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
cp -r /tmp/apache-tomcat-10.1.26/* /usr/local/tomcat
chown -R tomcat.tomcat /usr/local/tomcat
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=10050/tcp --permanent
firewall-cmd --reload
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip -O maven.zip
unzip maven.zip
cp -r apache-maven-3.9.9 /usr/local/maven3.9
export MAVEN_OPTS="-Xmx512m"
cd /vagrant/vprofile-project
/usr/local/maven3.9/bin/mvn install
systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target /vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
chown -R tomcat.tomcat /usr/local/tomcat/webapps
systemctl restart tomcat
chmod +x /vagrant/zabbix-agent-*
bash /vagrant/zabbix-agent-centos9.sh

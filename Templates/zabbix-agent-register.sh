#!/usr/bin/env bash

zabbix_server="$1"
node_to_register=$(hostname -I | awk '{print $2}')
zabbix_username="Admin"
zabbix_password='zabbix'

cat <<EOF > body1.json
{
  "jsonrpc": "2.0",
  "method": "user.login",
  "params": {
    "username": "$zabbix_username",
    "password": "$zabbix_password"
  },
  "id": 0
}
EOF

token=$(curl -s -X POST "http://$zabbix_server/api_jsonrpc.php" -H 'Content-Type: application/json' -d @body1.json | awk '{print $2}' FS="," | tr -d '"' | awk '{print $2}' FS=":")

cat <<EOF > body2.json
{
  "jsonrpc": "2.0",
  "method": "host.create",
  "params": {
    "host": "$(hostname -f)",
    "interfaces": [
      {
        "type": 1,
        "main": 1,
        "useip": 1,
	"ip": "$node_to_register",
        "dns": "1.1.1.1",
        "port": "10050"
      }
    ],
    "groups": [
      {
        "groupid": "2"
      }
    ],
    "templates": [
      {
        "templateid": "10001",
        "templateid": "10001"
      }
    ]
  },
  "id": 2
}
EOF

curl -s -X POST "http://$zabbix_server/api_jsonrpc.php" -H 'Content-Type: application/json' -H "Authorization: Bearer $token" -d @body2.json

rm {body1.json,body2.json}

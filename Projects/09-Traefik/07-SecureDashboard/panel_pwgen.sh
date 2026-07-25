#!/usr/bin/env bash

creds_path="./secrets/traefik-dashboard-creds"

while getopts "u:p:" opt; do
  case ${opt} in
    u) user="$OPTARG" ;;
    p) password="$OPTARG" ;;
    \?) echo -e "\n[!] Bad parameter, exiting...\n" && exit 1;;
  esac
done

if [[ -z "$user"  ]] || [[ -z "$password" ]]; then
  echo -e "\n[!] User or password not defined, exiting..."
  echo -e "\n\t[+] Usage: $0 --user <username> --password <password>\n"
  exit 1
else
  creds=$(docker run --rm carlosguerrer0/htpasswd:v1 -nb "$user" "$password")
  echo "$creds" > "$creds_path" 
  echo "[+] Credentials saved to $creds_path"
  exit 0
fi

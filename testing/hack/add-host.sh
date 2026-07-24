#!/bin/bash

# Add local domain resolution
# Parameters:
#   $1: Domain name
#   $2: IP address
#
# DEVOPS-44489: best-effort. Non-root/PSA-restricted environments cannot
# write /etc/hosts -- warn and exit 0 rather than failing the scenario;
# those environments rely on the bdd fake resolver + nss_wrapper fallback
# instead (see network.feature's "已添加域名解析" step + run-e2e.sh).

DOMAIN=$1
IP=$2

echo "Adding local Hosts: $DOMAIN -> $IP"

# Add local domain resolution (best-effort)
if grep -q "$IP $DOMAIN" /etc/hosts 2>/dev/null; then
  echo "Local Hosts already exists: $DOMAIN -> $IP"
elif echo "$IP $DOMAIN" >> /etc/hosts 2>/dev/null; then
  echo "Local Hosts added successfully: $DOMAIN -> $IP"
else
  echo "WARN: /etc/hosts not writable (non-root PSA env); relying on bdd fake resolver + nss_wrapper"
fi

exit 0

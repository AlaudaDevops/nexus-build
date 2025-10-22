#!/bin/bash

# Add local domain resolution
# Parameters:
#   $1: Domain name
#   $2: IP address

DOMAIN=$1
IP=$2

echo "Adding local Hosts: $DOMAIN -> $IP"

# Add local domain resolution
if ! grep -q "$IP $DOMAIN" /etc/hosts; then
  echo "$IP $DOMAIN" >> /etc/hosts
  echo "Local Hosts added successfully: $DOMAIN -> $IP"
else
  echo "Local Hosts already exists: $DOMAIN -> $IP"
fi

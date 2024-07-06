#!/usr/bin/env bash

#title            :update_dyndns_hosts.sh
#description      :Update the IP address of the specified subdomains registered with Namecheap.com.
#author           :J.D. Stone
#date             :20240705
#version          :0.6.0
#usage            :Add your domain and subdomain(s) below and run script.
#notes            :Curl must be installed


# Domain to update
DOMAIN=""
# Subdomains to update
declare -a SUB_DOMAINS=("sub1" "sub2")
# My current public IP address
CURRENT_PUBLIC_IP="$(curl -4 -s https://ifconfig.co/ip)"
# Dynamic DNS password (provided by Namecheap)
PASSWORD=""

# Loop through each subdomain. If the domain's
#  IP is different than my current public IP,
#  update the IP address.
for subdomain in "${SUB_DOMAINS[@]}"; do
    SUB_DOMAIN_IP="$(dig "${subdomain}"."${DOMAIN}" +short)"

    if [ "${SUB_DOMAIN_IP}" != "${CURRENT_PUBLIC_IP}" ]; then
        curl -s -G --data-urlencode domain="${DOMAIN}" --data-urlencode password="${PASSWORD}" --data-urlencode host="${subdomain}" https://dynamicdns.park-your-domain.com/update?ip="${CURRENT_PUBLIC_IP}" 1> /dev/null
    fi
done



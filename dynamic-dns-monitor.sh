#!/bin/bash

# Checks for public IP(v4) changes and curls dynamic DNS update URL if necessary.
# Provide update URL as first argument.

set -e

UPDATE_URL="$1"
LOG_FILE='/var/log/dynamic-dns-monitor.log'
TEMP_FILE='/tmp/.dynamic-dns-last-ip'

current_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

[[ -e $TEMP_FILE ]] && last_ip=$(cat "$TEMP_FILE")

if [[ $last_ip == $current_ip ]]; then
    echo "No change"
    exit 0
else
    echo "Updating IP"
    curl "$UPDATE_URL"
    echo "$current_ip" > "$TEMP_FILE"
    if [[ -z $last_ip ]]; then
        echo "$(date) - No old IPv4 address found. New IP: ${current_ip}" >> "$LOG_FILE"
    else
        echo "$(date) - IPv4 address changed. Old IP: ${last_ip} New IP: ${current_ip}" >> "$LOG_FILE"
    fi
fi

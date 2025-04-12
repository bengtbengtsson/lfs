#!/bin/bash
set -euo pipefail

INTERFACE="wlp1s0"
SSID="Bengtsson"

read -rsp "🔐 Enter Wi-Fi password for SSID '$SSID': " WIFI_PASS
echo

echo "📡 Connecting to $SSID via $INTERFACE..."

# Start wpa_supplicant in the background using an ephemeral config
wpa_passphrase "$SSID" "$WIFI_PASS" | \
    wpa_supplicant -B -i "$INTERFACE" -c /dev/stdin

echo "🌐 Requesting IP via DHCP..."
dhcpcd "$INTERFACE"

echo "✅ Connected. Try pinging a site or your router!"


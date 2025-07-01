#!/bin/bash
set -e

# Create config directory
mkdir -p /usr/local/etc/xray

# Generate UUID and key pair
UUID=$(xray uuid)
KEY_PAIR=$(xray x25519)
PRIVATE=$(echo "$KEY_PAIR" | grep Private | awk '{print $2}')
PUBLIC=$(echo "$KEY_PAIR" | grep Public | awk '{print $2}')
SHORT=$(openssl rand -hex 6)

# Create the Xray config file
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "$UUID",
        "flow": "xtls-rprx-vision"
      }]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "privateKey": "$PRIVATE",
        "shortIds": ["$SHORT"],
        "serverName": "www.google.com",
        "publicKey": "$PUBLIC"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF

# Print connection details
echo "UUID: $UUID"
echo "PublicKey: $PUBLIC"
echo "ShortID: $SHORT"
echo "SNI: www.google.com"

# Validate configuration
echo "Validating configuration..."
/usr/local/bin/xray run -test -config /usr/local/etc/xray/config.json

# Start cron and supervisor
service cron start
exec supervisord -n

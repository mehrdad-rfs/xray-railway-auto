#!/bin/bash
set -e

mkdir -p /usr/local/etc/xray

UUID=$(xray uuid)
KEY_PAIR=$(xray x25519)
PRIVATE=$(echo "$KEY_PAIR" | grep Private | awk '{print $2}')
PUBLIC=$(echo "$KEY_PAIR" | grep Public | awk '{print $2}')
SHORT=$(openssl rand -hex 6)

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
        "serverNames": ["www.google.com"],
        "publicKey": "$PUBLIC"
      }
    }
  }],
  "outbounds": [{"protocol": "freedom","settings":{}}]
}
EOF

echo "UUID: $UUID"
echo "PublicKey: $PUBLIC"
echo "ShortID: $SHORT"
echo "SNI: www.google.com"

service cron start
exec supervisord -n
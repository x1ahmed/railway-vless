#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray config directly with fixed values
cat << EOF > ${DIR_TMP}/config.json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {        "clients": [
          {
            "id": "3c129bec-f357-449d-abe5-66a33edbbed0",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "partners.playstation.net:443",
          "xver": 0,
          "serverNames": [
            "partners.playstation.net"
          ],
          "privateKey": "4PqTjiQoiiOVgPTTTne42qHvgygFixTfVU2xO_-BL34",
          "shortIds": [
            "8236"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ],
  "stats": {},
  "policy": {
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
EOF

echo "✅ Config created at ${DIR_TMP}/config.json"

# Download latest V2Ray
echo "⬇️ Downloading V2Ray..."
curl -L -o ${DIR_TMP}/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip

# Unzip without prompt
echo "📦 Extracting..."
unzip -o ${DIR_TMP}/v2ray.zip -d ${DIR_TMP}

# Validate binary
if [ ! -f "${DIR_TMP}/v2ray" ]; then
  echo "❌ v2ray binary not found after unzip!"
  ls -la ${DIR_TMP}
  exit 1
fi

# Install binaries
echo "🔧 Installing..."
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}/v2ray
[ -f "${DIR_TMP}/geoip.dat" ] && install -m 644 ${DIR_TMP}/geoip.dat ${DIR_RUNTIME}/geoip.dat
[ -f "${DIR_TMP}/geosite.dat" ] && install -m 644 ${DIR_TMP}/geosite.dat ${DIR_RUNTIME}/geosite.dat

# Move config
mkdir -p ${DIR_CONFIG}
mv ${DIR_TMP}/config.json ${DIR_CONFIG}/config.json

# Cleanup
rm -rf ${DIR_TMP}

# Run
echo "🚀 Starting V2Ray on port 443..."
exec ${DIR_RUNTIME}/v2ray run -config=${DIR_CONFIG}/config.json

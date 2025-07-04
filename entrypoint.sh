#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray configuration (only one inbound using TCP + Reality)
cat << EOF > ${DIR_TMP}/heroku.json
{
    {
      "inbounds": [
        {
          "port": 17306,
          "protocol": "vless",
          "settings": {
            "clients": [
              {
                "id": "8442ff27-8e79-4f27-b4d2-c3e6447789ea",
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
              "privateKey": "8GXPCvZ4ty3uEKxexznrZvCSo3NqYwzKY5dzbaQGWVM",
              "shortIds": [
                "8236"
              ]
            }
          }
        },
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
}
EOF

# Get V2Ray executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip
busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Convert to protobuf format configuration
mkdir -p ${DIR_CONFIG}
${DIR_TMP}/v2ctl config ${DIR_TMP}/heroku.json > ${DIR_CONFIG}/config.pb

# Install V2Ray
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
rm -rf ${DIR_TMP}

# Run V2Ray
${DIR_RUNTIME}/v2ray -config=${DIR_CONFIG}/config.pb

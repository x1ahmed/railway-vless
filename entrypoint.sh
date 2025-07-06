#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray configuration
cat << EOF > ${DIR_TMP}/config.json
{
  "inbounds": [{
    "port": ${PORT},
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "${ID}"
      }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "${WSPATH}"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

# Get V2Ray executable release
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray_dist.zip
busybox unzip ${DIR_TMP}/v2ray_dist.zip -d ${DIR_TMP}

# Move v2ray binary
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
install -m 755 ${DIR_TMP}/geo* ${DIR_RUNTIME}

# Prepare config folder
mkdir -p ${DIR_CONFIG}
mv ${DIR_TMP}/config.json ${DIR_CONFIG}/config.json

# Cleanup
rm -rf ${DIR_TMP}

# Run V2Ray with JSON config
${DIR_RUNTIME}/v2ray run -config=${DIR_CONFIG}/config.json

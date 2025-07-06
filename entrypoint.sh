#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/bin"
DIR_TMP="$(mktemp -d)"

# Write V2Ray configuration
cat << EOF > ${DIR_TMP}/config.json
{
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "aa334de3-ee82-4218-86ca-47ec4ce5fd1b"
      }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "path": "/"
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

# Download and unzip V2Ray core
curl -fsSL https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o ${DIR_TMP}/v2ray.zip
busybox unzip ${DIR_TMP}/v2ray.zip -d ${DIR_TMP}

# Install v2ray
install -m 755 ${DIR_TMP}/v2ray ${DIR_RUNTIME}
install -m 755 ${DIR_TMP}/geo* ${DIR_RUNTIME}

# Setup config
mkdir -p ${DIR_CONFIG}
mv ${DIR_TMP}/config.json ${DIR_CONFIG}/config.json

# Clean up
rm -rf ${DIR_TMP}

# Run v2ray
echo "Starting V2Ray on port ${PORT}..."
exec ${DIR_RUNTIME}/v2ray run -config=${DIR_CONFIG}/config.json

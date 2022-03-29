#!/usr/bin/env bash

set -o xtrace

EXTENSION_NAME=${1}
TARGET_DIR="/opt/hivemq/extensions/${EXTENSION_NAME}"
cd ${TARGET_DIR}


if [[ -f init_tmp ]]; then
    echo "Using temporary init file"
    chmod +x init_tmp
    echo "Executing initialization script"
    ./init_tmp
    rm -f ./init_tmp
else
    if [[ -f "/etc/podinfo/init-extension-${EXTENSION_NAME}" ]]; then
        echo "Using init script from config map"
        # because config map is r/o
        cat "/etc/podinfo/init-extension-${EXTENSION_NAME}" > ./init
        echo "Executing initialization script"
        chmod +x init
        ./init
    fi
fi
#!/usr/bin/env bash

set -eo pipefail

# Decode license and put file if present
if [ -n "${HIVEMQ_LICENSE}" ]; then
    echo "Decoding license..."
    echo ${HIVEMQ_LICENSE} | base64 -d > /opt/hivemq/license/license.lic
fi

# We set the bind address here to ensure HiveMQ uses the correct interface. Defaults to using the container hostname (which should be hardcoded in /etc/hosts)
if [ -z "${HIVEMQ_BIND_ADDRESS}" ]; then
    echo "Getting bind address from container hostname"
    ADDR=$(getent hosts ${HOSTNAME} | grep -v 127.0.0.1 | awk '{ print $1 }' | head -n 1)
else
    echo "HiveMQ bind address was overridden by environment variable (value: ${HIVEMQ_BIND_ADDRESS})"
    ADDR=${HIVEMQ_BIND_ADDRESS}
fi

echo "set bind address from container hostname to ${ADDR}"
export HIVEMQ_BIND_ADDRESS=${ADDR}

# Step down from root privilege, only when we're attempting to run HiveMQ though.
if [[ "$1" = '/opt/hivemq/bin/run.sh' && "$(id -u)" = '0' && "${HIVEMQ_NO_ROOT_STEP_DOWN}" != "true" ]]; then
    # Restrict HiveMQ folder permissions
    chown -R hivemq:hivemq /opt/hivemq*
    chmod -R 750 /opt/hivemq*
    HIVEMQ_BIND_ADDRESS=${ADDR} exec gosu hivemq "$BASH_SOURCE" "$@"
fi

# Default if we're not running HiveMQ
HIVEMQ_BIND_ADDRESS=${ADDR} exec "$@"
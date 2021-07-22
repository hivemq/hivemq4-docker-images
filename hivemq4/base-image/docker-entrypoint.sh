#!/usr/bin/env bash

set -eo pipefail

if [[ "${HIVEMQ_VERBOSE_ENTRYPOINT}" == "true" ]]; then
    exec 3>&1
else
    exec 3>/dev/null
fi

# Decode license and put file if present
if [[ -n "${HIVEMQ_LICENSE}" ]]; then
    echo >&3 "Decoding license..."
    echo ${HIVEMQ_LICENSE} | base64 -d > /opt/hivemq/license/license.lic
fi

# We set the bind address here to ensure HiveMQ uses the correct interface. Defaults to using the container hostname (which should be hardcoded in /etc/hosts)
if [[ -z "${HIVEMQ_BIND_ADDRESS}" ]]; then
    echo >&3 "Getting bind address from container hostname"
    ADDR=$(getent hosts ${HOSTNAME} | grep -v 127.0.0.1 | awk '{ print $1 }' | head -n 1)
else
    echo >&3 "HiveMQ bind address was overridden by environment variable (value: ${HIVEMQ_BIND_ADDRESS})"
    ADDR=${HIVEMQ_BIND_ADDRESS}
fi

# Remove allow all extension if applicable
if [[ "${HIVEMQ_ALLOW_ALL_CLIENTS}" != "true" ]]; then
    echo "Disabling allow all extension"
    rm -rf /opt/hivemq/extensions/hivemq-allow-all-extension &>/dev/null || true
fi


if [[ "${HIVEMQ_REST_API_ENABLED}" == "true" ]]; then
  REST_API_ENABLED_CONFIGURATION="<rest-api>
        <enabled>true</enabled>
        <listeners>
            <http>
                <port>8888</port>
                <bind-address>0.0.0.0</bind-address>
            </http>
        </listeners>
    </rest-api>"
  echo "Enabling REST API in config.xml..."
  REST_API_ENABLED_CONFIGURATION="${REST_API_ENABLED_CONFIGURATION//$'\n'/}"
  sed -i "s|<\!--REST-API-CONFIGURATION-->|${REST_API_ENABLED_CONFIGURATION}|" /opt/hivemq/conf/config.xml
fi

echo "set bind address from container hostname to ${ADDR}"
export HIVEMQ_BIND_ADDRESS=${ADDR}

# Run entrypoint parts
find "/docker-entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
  if [ -x "$f" ]; then
    echo >&3 "$0: running $f"
    "$f"
  else
    echo >&3 "$0: sourcing $f"
    . "$f"
  fi
done

# Step down from root privilege, only when we're attempting to run HiveMQ though.
if [[ "$1" = "/opt/hivemq/bin/run.sh" && "$(id -u)" = '0' && "${HIVEMQ_NO_ROOT_STEP_DOWN}" != "true" ]]; then
    uid="hivemq"
    gid="hivemq"
    exec_cmd="exec gosu hivemq:hivemq"
else
    uid="$(id -u)"
    gid="$(id -g)"
    exec_cmd="exec"
fi

readonly uid
readonly gid
readonly exec_cmd

if [[ "$(id -u)" = "0" ]]; then
    # Restrict HiveMQ folder permissions, non-recursive so we don't touch volumes
    chown "${uid}":"${gid}" /opt/hivemq/data
    # Any of the following may fail but should still allow HiveMQ to start normally, so lets ignore errors
    set +e
    (
    chown "${uid}":"${gid}" /opt
    chown "${uid}":"${gid}" /opt/hivemq
    chown "${uid}":"${gid}" /opt/hivemq-*
    chown "${uid}":"${gid}" /opt/hivemq/audit
    chown "${uid}":"${gid}" /opt/hivemq/log
    chown "${uid}":"${gid}" /opt/hivemq/conf
    chown "${uid}":"${gid}" /opt/hivemq/conf/config.xml
    chown "${uid}":"${gid}" /opt/hivemq/license
    chown "${uid}":"${gid}" /opt/hivemq/backup
    chown "${uid}":"${gid}" /opt/hivemq/tools
    chown "${uid}":"${gid}" /opt/hivemq/extensions
    # Recursive for bin, no volume here
    chown -R "${uid}":"${gid}" /opt/hivemq/bin
    chmod 700 /opt/hivemq
    chmod 700 /opt/hivemq-*
    chmod -R 700 /opt/hivemq/bin
    ) 2>/dev/null
fi

HIVEMQ_BIND_ADDRESS=${ADDR} ${exec_cmd} "$@"

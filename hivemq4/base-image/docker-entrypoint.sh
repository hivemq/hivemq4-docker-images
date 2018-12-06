#!/usr/bin/env bash

set -eo pipefail

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
    chown "${uid}":"${gid}" /opt/hivemq
    chown "${uid}":"${gid}" /opt/hivemq-*
    chown "${uid}":"${gid}" /opt/hivemq/data
    chown "${uid}":"${gid}" /opt/hivemq/log
    chown "${uid}":"${gid}" /opt/hivemq/conf
    chown "${uid}":"${gid}" /opt/hivemq/license
    # Recursive for bin, no volume here
    chown -R "${uid}":"${gid}" /opt/hivemq/bin
    chmod 700 /opt/hivemq*
    chmod 700 /opt/hivemq-*
    chmod -R 700 /opt/hivemq/bin
fi

${exec_cmd} "$@"
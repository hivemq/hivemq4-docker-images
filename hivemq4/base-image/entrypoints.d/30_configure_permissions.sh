#!/usr/bin/env bash

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
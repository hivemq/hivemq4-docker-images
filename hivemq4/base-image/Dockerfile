FROM openjdk:11-jre-slim as javabase

ENV HIVEMQ_GID=10000
ENV HIVEMQ_UID=10000

# Additional JVM options, may be overwritten by user
ENV JAVA_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA"

# Default allow all extension, set this to false to disable it
ENV HIVEMQ_ALLOW_ALL_CLIENTS "true"

# Enable REST API default value
ENV HIVEMQ_REST_API_ENABLED "false"

# gosu for root step-down to user-privileged process
ENV GOSU_VERSION 1.11

# Whether we should print additional debug info for the entrypoints
ENV HIVEMQ_VERBOSE_ENTRYPOINT "false"

# Whether nss_wrapper should be used for starting HiveMQ. Can be disabled for container runtimes that natively fixes the user information in the container at run-time like CRI-O.
ENV HIVEMQ_USE_NSS_WRAPPER "true"

# Set locale
ENV LANG=en_US.UTF-8

# gosu setup
RUN set -x \
        && apt-get update && apt-get install -y --no-install-recommends curl gnupg-agent gnupg dirmngr unzip libnss-wrapper \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" -o /usr/local/bin/gosu.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
        && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
        && { command -v gpgconf && gpgconf --kill all || :; } \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-get purge -y gpg dirmngr && rm -rf /var/lib/apt/lists/*


#Additional build image to unpack the zip file and change the permissions without retaining large layers just for those operations
FROM javabase as unpack

ARG HIVEMQ_VERSION=4.0.0

COPY config.xml /opt/config.xml
COPY hivemq-${HIVEMQ_VERSION}.zip /opt/hivemq-${HIVEMQ_VERSION}.zip
RUN  unzip /opt/hivemq-${HIVEMQ_VERSION}.zip  -d /opt/ \
     && rm -rf /opt/hivemq-${HIVEMQ_VERSION}/tools/hivemq-swarm \
     && mv /opt/config.xml /opt/hivemq-${HIVEMQ_VERSION}/conf/config.xml \
     && chgrp -R 0 /opt \
     && chmod -R 770 /opt

FROM javabase

ARG HIVEMQ_VERSION=4.0.0

COPY --from=unpack /opt/hivemq-${HIVEMQ_VERSION} /opt/hivemq
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
COPY entrypoints.d/* /docker-entrypoint.d/

RUN mkdir -p /docker-entrypoint.d \
    && groupadd --gid ${HIVEMQ_GID} hivemq \
    && useradd -g hivemq -d /opt/hivemq -s /bin/bash --uid ${HIVEMQ_UID} hivemq \
    && chmod +x /opt/hivemq/bin/run.sh /opt/docker-entrypoint.sh

# Substitute eval for exec and replace OOM flag if necessary (for older releases). This is necessary for proper signal propagation
RUN sed -i -e 's|eval \\"java\\" "$HOME_OPT" "$JAVA_OPTS" -jar "$JAR_PATH"|exec "java" $HOME_OPT $JAVA_OPTS -jar "$JAR_PATH"|' /opt/hivemq/bin/run.sh && \
    sed -i -e "s|-XX:OnOutOfMemoryError='sleep 5; kill -9 %p'|-XX:+CrashOnOutOfMemoryError|" /opt/hivemq/bin/run.sh

# Make broker data persistent throughout stop/start cycles
VOLUME /opt/hivemq/data

# Persist log data
VOLUME /opt/hivemq/log

#mqtt-clients
EXPOSE 1883

#websockets
EXPOSE 8000

#HiveMQ Control Center
EXPOSE 8080

WORKDIR /opt/hivemq

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["/opt/hivemq/bin/run.sh"]

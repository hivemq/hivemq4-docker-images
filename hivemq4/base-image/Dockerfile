# Additional build image to unpack the zip file and change the permissions without retaining large layers just for those operations
FROM busybox:1.36.1@sha256:c3839dd800b9eb7603340509769c43e146a74c63dca3045a8e7dc8ee07e53966 AS unpack

ARG HIVEMQ_VERSION

COPY hivemq-${HIVEMQ_VERSION}.zip /tmp/hivemq.zip
RUN unzip /tmp/hivemq.zip -d /opt \
    && mv /opt/hivemq-${HIVEMQ_VERSION} /opt/hivemq \
    && rm -rf /opt/hivemq/tools/hivemq-swarm
COPY config.xml /opt/hivemq/conf/config.xml
RUN chmod -R 770 /opt/hivemq \
    && chmod +x /opt/hivemq/bin/run.sh


# Actual image
FROM eclipse-temurin:11.0.22_7-jre-jammy@sha256:ec48c245e50016d20c36fd3cdd5b4e881eee68cab535955df74a8a9ec709faaa

ARG HIVEMQ_GID=10000
ARG HIVEMQ_UID=10000

# Additional JVM options, may be overwritten by user
ENV JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA"

# Default allow all extension, set this to false to disable it
ENV HIVEMQ_ALLOW_ALL_CLIENTS=true

# Enable REST API default value
ENV HIVEMQ_REST_API_ENABLED=false

# Whether we should print additional debug info for the entrypoints
ENV HIVEMQ_VERBOSE_ENTRYPOINT=false

# Set locale
ENV LANG=en_US.UTF-8

RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /docker-entrypoint.d

# HiveMQ setup
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
COPY entrypoints.d/* /docker-entrypoint.d/
COPY --from=unpack /opt/hivemq /opt/hivemq
RUN chmod +x /opt/docker-entrypoint.sh \
    && groupadd --gid ${HIVEMQ_GID} hivemq \
    && useradd -g hivemq -d /opt/hivemq -s /bin/bash --uid ${HIVEMQ_UID} hivemq \
    && chmod 770 /opt/hivemq

# Make broker data persistent throughout stop/start cycles
VOLUME /opt/hivemq/data

# Persist log data
VOLUME /opt/hivemq/log

# MQTT TCP listener: 1883
# MQTT Websocket listener: 8000
# HiveMQ Control Center: 8080
EXPOSE 1883 8000 8080

WORKDIR /opt/hivemq

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["/opt/hivemq/bin/run.sh"]

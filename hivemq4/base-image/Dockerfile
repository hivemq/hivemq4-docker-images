# Additional build image to unpack the zip file and change the permissions without retaining large layers just for those operations
FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b AS unpack

ARG HIVEMQ_VERSION

COPY hivemq-${HIVEMQ_VERSION}.zip /tmp/hivemq.zip
RUN unzip /tmp/hivemq.zip -d /opt \
    && mv /opt/hivemq-${HIVEMQ_VERSION} /opt/hivemq \
    && rm -rf /opt/hivemq/tools/hivemq-swarm
COPY config.xml /opt/hivemq/conf/config.xml
RUN find /opt/hivemq -type d -print0 | xargs -0 chmod 770 \
    && find /opt/hivemq -type f -print0 | xargs -0 chmod 660 \
    && chmod 770 /opt/hivemq/**/*.sh \
    && chmod 770 /opt/hivemq/tools/mqtt-cli*/bin/mqtt \
    && chmod 770 /opt/hivemq/extensions/hivemq-enterprise-security-extension/helper/linux/hivemq-ese-helper


# Actual image
FROM eclipse-temurin:21.0.2_13-jre-jammy@sha256:603d23272e30bbefa9e7c436a7165c6303b9c67e27aae07472d8ddc748fe96a2

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

# HiveMQ entrypoint
COPY --chmod=755 docker-entrypoint.sh /opt/docker-entrypoint.sh
RUN mkdir -p /docker-entrypoint.d
COPY --chmod=644 20_handle_envs.sh /docker-entrypoint.d/20_handle_envs.sh

# HiveMQ
COPY --from=unpack /opt/hivemq /opt/hivemq
RUN chmod 770 /opt/hivemq

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

USER 10000

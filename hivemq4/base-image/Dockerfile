# Additional build image to unpack the zip file and change the permissions without retaining large layers just for those operations
FROM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 AS unpack

ARG HIVEMQ_VERSION

COPY hivemq-${HIVEMQ_VERSION}.zip /tmp/hivemq.zip
RUN unzip /tmp/hivemq.zip -d /opt \
    && mv /opt/hivemq-${HIVEMQ_VERSION} /opt/hivemq \
    && rm -rf /opt/hivemq/tools/hivemq-swarm
COPY config.xml /opt/hivemq/conf/config.xml
RUN find /opt/hivemq -type d -print0 | xargs -0 chmod 750 \
    && find /opt/hivemq -type f -print0 | xargs -0 chmod 640 \
    # files that need execute permissions
    && chmod 750 /opt/hivemq/**/*.sh \
    && chmod 750 /opt/hivemq/tools/mqtt-cli*/bin/mqtt || true \
    && chmod 750 /opt/hivemq/extensions/hivemq-enterprise-security-extension/helper/linux/hivemq-ese-helper || true \
    # directories that need write permissions
    && chmod 770 /opt/hivemq/audit \
    && chmod 770 /opt/hivemq/backup \
    && chmod 770 /opt/hivemq/conf \
    && chmod 770 /opt/hivemq/data \
    && chmod 770 /opt/hivemq/extensions \
    && chmod 770 /opt/hivemq/extensions/* \
    && chmod 770 /opt/hivemq/extensions/*/conf || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-amazon-kinesis-extension/customizations || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-enterprise-security-extension/drivers || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-enterprise-security-extension/drivers/jdbc || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-google-cloud-pubsub-extension/customizations || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-kafka-extension/customizations || true \
    && chmod 770 /opt/hivemq/extensions/hivemq-kafka-extension/local-schema-registry || true \
    && chmod 770 /opt/hivemq/license \
    && chmod 770 /opt/hivemq/log \
    # files that need write permissions
    && chmod 660 /opt/hivemq/conf/config.xml \
    && chmod 660 /opt/hivemq/conf/logback.xml \
    && chmod 660 /opt/hivemq/conf/tracing.xml \
    && chmod 660 /opt/hivemq/extensions/*/DISABLED || true \
    && chmod 660 /opt/hivemq/extensions/*/hivemq-extension.xml || true


# Actual image
FROM eclipse-temurin:21.0.4_7-jre-jammy@sha256:948f1a18cd58bde76d3068b1d8c69c2b5d705298687cd5090b09d836036a17ab

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

# As the user id that runs the container (10000 by default) does not have an entry in /etc/passwd, set the home directory explicitly.
# If not set, HOME would default to "/".
# Java uses this value for the system property "user.home" (used for example by the mqtt-cli).
ENV HOME=/opt/hivemq

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

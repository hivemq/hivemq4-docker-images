ARG BASEIMAGE=hivemq/hivemq4:dns-latest


# Additional build image to unpack the zip files and change the permissions without retaining large layers just for those operations
FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b AS unpack

ARG PROMETHEUS_EXTENSION_VERSION=4.0.9

RUN mkdir -p /opt/hivemq/extensions

# Unpack hivemq-k8s-sync-extension
COPY hivemq-k8s-sync-extension-*.zip /tmp/hivemq-k8s-sync-extension.zip
RUN unzip /tmp/hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-k8s-sync-extension.zip \
    && find /opt/hivemq/extensions/hivemq-k8s-sync-extension -type d -print0 | xargs -0 chmod 770 \
    && find /opt/hivemq/extensions/hivemq-k8s-sync-extension -type f -print0 | xargs -0 chmod 660

# Unpack hivemq-prometheus-extension
RUN apk --update add curl \
    && curl -L https://github.com/hivemq/hivemq-prometheus-extension/releases/download/${PROMETHEUS_EXTENSION_VERSION}/hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip -o /tmp/hivemq-prometheus-extension.zip \
    && unzip /tmp/hivemq-prometheus-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-prometheus-extension.zip \
    && rm /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
RUN find /opt/hivemq/extensions/hivemq-prometheus-extension -type d -print0 | xargs -0 chmod 770 \
    && find /opt/hivemq/extensions/hivemq-prometheus-extension -type f -print0 | xargs -0 chmod 660


# Actual image
FROM ${BASEIMAGE}

USER 0

ENV HIVEMQ_LOG_LEVEL=INFO\
    HIVEMQ_CLUSTER_TRANSPORT_TYPE=TCP

COPY --chmod=660 config.xml /opt/hivemq/conf/config.xml
COPY --chmod=755 15_k8s_entrypoint.sh /docker-entrypoint.d/15_k8s_entrypoint.sh
COPY --chmod=770 scripts/*.sh /opt/hivemq/bin/
COPY --from=unpack /opt/hivemq/extensions/ /opt/hivemq/extensions/

RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images

USER 10000

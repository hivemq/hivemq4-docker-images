ARG BASEIMAGE=hivemq/hivemq4:dns-latest


# Additional build image to unpack the zip files and change the permissions without retaining large layers just for those operations
FROM alpine:3.20@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d AS unpack

ARG PROMETHEUS_EXTENSION_VERSION=4.0.11

RUN mkdir -p /opt/hivemq/extensions

# Unpack hivemq-k8s-sync-extension
COPY hivemq-k8s-sync-extension-*.zip /tmp/hivemq-k8s-sync-extension.zip
RUN unzip /tmp/hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-k8s-sync-extension.zip \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension

# Unpack hivemq-prometheus-extension
RUN apk --update add curl \
    && curl -L https://github.com/hivemq/hivemq-prometheus-extension/releases/download/${PROMETHEUS_EXTENSION_VERSION}/hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip -o /tmp/hivemq-prometheus-extension.zip \
    && unzip /tmp/hivemq-prometheus-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-prometheus-extension.zip \
    && rm /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
RUN chmod -R 770 /opt/hivemq/extensions/hivemq-prometheus-extension


# Actual image
FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL=INFO\
    HIVEMQ_CLUSTER_TRANSPORT_TYPE=TCP

COPY --chmod=770 config.xml /opt/hivemq/conf/config.xml
COPY --chmod=755 15_k8s_entrypoint.sh /docker-entrypoint.d/15_k8s_entrypoint.sh
COPY --chmod=755 scripts/*.sh /opt/hivemq/bin/
COPY --from=unpack /opt/hivemq/extensions/ /opt/hivemq/extensions/

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images

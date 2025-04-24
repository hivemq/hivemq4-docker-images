ARG BASEIMAGE=hivemq/hivemq4:dns-latest


# Additional build image to unpack the zip files and change the permissions without retaining large layers just for those operations
FROM alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c AS unpack

ARG PROMETHEUS_EXTENSION_VERSION=4.0.12

RUN mkdir -p /opt/hivemq/extensions

# Unpack hivemq-k8s-sync-extension
COPY hivemq-k8s-sync-extension-*.zip /tmp/hivemq-k8s-sync-extension.zip
RUN unzip /tmp/hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-k8s-sync-extension.zip \
    && find /opt/hivemq/extensions/hivemq-k8s-sync-extension -type d -print0 | xargs -0 chmod 750 \
    && find /opt/hivemq/extensions/hivemq-k8s-sync-extension -type f -print0 | xargs -0 chmod 640 \
    # directories that need write permissions
    && chmod 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    # files that need write permissions
    && chmod 660 /opt/hivemq/extensions/hivemq-k8s-sync-extension/hivemq-extension.xml

# Unpack hivemq-prometheus-extension
RUN apk --update add curl \
    && curl -L https://github.com/hivemq/hivemq-prometheus-extension/releases/download/${PROMETHEUS_EXTENSION_VERSION}/hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip -o /tmp/hivemq-prometheus-extension.zip \
    && unzip /tmp/hivemq-prometheus-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-prometheus-extension.zip \
    && rm /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
RUN find /opt/hivemq/extensions/hivemq-prometheus-extension -type d -print0 | xargs -0 chmod 750 \
    && find /opt/hivemq/extensions/hivemq-prometheus-extension -type f -print0 | xargs -0 chmod 640 \
    # directories that need write permissions
    && chmod 770 /opt/hivemq/extensions/hivemq-prometheus-extension \
    # files that need write permissions
    && chmod 660 /opt/hivemq/extensions/hivemq-prometheus-extension/hivemq-extension.xml \
    && chmod 660 /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties


# Actual image
FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL=INFO\
    HIVEMQ_CLUSTER_TRANSPORT_TYPE=TCP

COPY --chmod=660 config.xml /opt/hivemq/conf/config.xml
COPY --chmod=755 15_k8s_entrypoint.sh /docker-entrypoint.d/15_k8s_entrypoint.sh
COPY --chmod=750 scripts/*.sh /opt/hivemq/bin/
COPY --from=unpack /opt/hivemq/extensions/ /opt/hivemq/extensions/

USER 0
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
USER 10000

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images

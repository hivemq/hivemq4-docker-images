ARG BASEIMAGE=hivemq/hivemq4:dns-latest
ARG PROMETHEUS_EXTENSION_VERSION=4.0.8

FROM alpine:3.19@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b as BUILD
ARG PROMETHEUS_EXTENSION_VERSION

RUN mkdir -p /opt/hivemq/extensions

COPY hivemq-k8s-sync-extension-*.zip /tmp/hivemq-k8s-sync-extension.zip
RUN unzip /tmp/hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-k8s-sync-extension.zip

RUN apk --update add curl && curl -L https://github.com/hivemq/hivemq-prometheus-extension/releases/download/${PROMETHEUS_EXTENSION_VERSION}/hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip -o /tmp/hivemq-prometheus-extension.zip \
    && unzip /tmp/hivemq-prometheus-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-prometheus-extension.zip \
    && rm /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties

## Clean image to distribute
FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL=INFO\
    HIVEMQ_CLUSTER_TRANSPORT_TYPE=TCP

COPY config.xml /opt/hivemq/conf/config.xml
COPY 15_k8s_entrypoint.sh /docker-entrypoint.d/15_k8s_entrypoint.sh
COPY scripts/*.sh /opt/hivemq/bin/
COPY --from=BUILD /opt/hivemq/extensions/ /opt/hivemq/extensions/

### Fix permissions as --chmod on COPY is not really working at the moment and requires buildkit
RUN chmod +x /opt/hivemq/bin/*.sh \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-prometheus-extension \
    && chmod 770 /opt/hivemq/conf/config.xml \
    && chmod 770 /docker-entrypoint.d/15_k8s_entrypoint.sh

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images

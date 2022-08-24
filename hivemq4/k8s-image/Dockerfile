
ARG BASEIMAGE=hivemq/hivemq4:dns-latest
ARG K8S_SYNC_EXTENSION_VERSION=4.7.5
ARG PROMETHEUS_EXTENSION_VERSION=4.0.4

FROM busybox:1.35.0 as BUILD
ARG K8S_SYNC_EXTENSION_VERSION
ARG PROMETHEUS_EXTENSION_VERSION

WORKDIR /opt/hivemq/extensions

COPY hivemq-k8s-sync-extension-"${K8S_SYNC_EXTENSION_VERSION}".zip ./hivemq-k8s-sync-extension.zip
RUN unzip hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    && rm hivemq-k8s-sync-extension.zip

ADD https://www.hivemq.com/releases/extensions/hivemq-prometheus-extension-"${PROMETHEUS_EXTENSION_VERSION}".zip ./hivemq-prometheus-extension.zip

RUN unzip hivemq-prometheus-extension.zip -d /opt/hivemq/extensions/hivemq-prometheus-extension \
    && rm hivemq-prometheus-extension.zip

COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/

FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL INFO
ENV HIVEMQ_CLUSTER_TRANSPORT_TYPE TCP

COPY config.xml /opt/hivemq/conf/config.xml
COPY scripts/*.sh /opt/hivemq/bin/
COPY --from=BUILD /opt/hivemq/extensions/* /opt/hivemq/extensions/

RUN rm /opt/hivemq/extensions/prometheusConfiguration.properties \
    && chmod +x /opt/hivemq/bin/*.sh \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    && chgrp -R 0 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-prometheus-extension \
    && chgrp -R 0 /opt/hivemq/extensions/hivemq-prometheus-extension \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension && chmod -R 770 /opt/hivemq/conf/config.xml

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images


ENTRYPOINT ["/opt/hivemq/bin/pre-entry_1.sh"]
CMD ["/opt/hivemq/bin/run.sh"]
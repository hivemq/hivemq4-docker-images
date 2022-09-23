ARG BASEIMAGE=hivemq/hivemq4:dns-latest
ARG PROMETHEUS_EXTENSION_VERSION=4.0.6

FROM busybox:1.35.0 as BUILD
ARG PROMETHEUS_EXTENSION_VERSION

WORKDIR /opt/hivemq/extensions

COPY hivemq-k8s-sync-extension-*.zip ./hivemq-k8s-sync-extension.zip
RUN unzip hivemq-k8s-sync-extension.zip -d /opt/hivemq/extensions/ \
    && rm hivemq-k8s-sync-extension.zip

RUN curl -L https://github.com/hivemq/hivemq-prometheus-extension/releases/download/${PROMETHEUS_EXTENSION_VERSION}/hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip > hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip \
    && unzip hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip -d /opt/hivemq/extensions/ \
    && rm hivemq-prometheus-extension-${PROMETHEUS_EXTENSION_VERSION}.zip /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/

## Clean image to distribute
FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL=INFO\
    HIVEMQ_CLUSTER_TRANSPORT_TYPE=TCP

COPY config.xml /opt/hivemq/conf/config.xml
COPY scripts/*.sh /opt/hivemq/bin/
COPY --from=BUILD /opt/hivemq/extensions/ /opt/hivemq/extensions/

### Move the entrypoint into the correct position & adjust for whether the base image uses entrypoint.d or not
### Fix permissions as --chmod on COPY is not really working at the moment and requires buildkit
RUN chmod +x /opt/hivemq/bin/*.sh \
    && if [ -d /docker-entrypoint.d ]; then \
      mv /opt/hivemq/bin/pre-entry_1.sh /docker-entrypoint.d/15_k8s_entrypoint.sh && \
      ln -s /opt/docker-entrypoint.sh /opt/hivemq/bin/pre-entry_1.sh; \
    else \
      echo '# Pass on to DNS entrypoint' >> /opt/hivemq/bin/pre-entry_1.sh && \
      echo 'exec /opt/pre-entry.sh "$@"' >> /opt/hivemq/bin/pre-entry_1.sh; \
    fi \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-prometheus-extension \
    && chmod -R 770 /opt/hivemq/conf/config.xml

LABEL org.opencontainers.image.vendor=HiveMQ\
      org.opencontainers.image.source=https://github.com/hivemq/hivemq4-docker-images

ENTRYPOINT ["/opt/hivemq/bin/pre-entry_1.sh"]
CMD ["/opt/hivemq/bin/run.sh"]
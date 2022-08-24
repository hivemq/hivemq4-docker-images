
ARG BASEIMAGE=hivemq/hivemq4:dns-latest

FROM ${BASEIMAGE}

ENV HIVEMQ_LOG_LEVEL INFO
ENV HIVEMQ_CLUSTER_TRANSPORT_TYPE TCP

RUN curl -L https://www.hivemq.com/releases/extensions/hivemq-prometheus-extension-4.0.4.zip > hivemq-prometheus-extension-4.0.4.zip \
    && unzip hivemq-prometheus-extension-4.0.4.zip -d /opt/hivemq/extensions/ \
    && rm hivemq-prometheus-extension-4.0.4.zip /opt/hivemq/extensions/hivemq-prometheus-extension/prometheusConfiguration.properties \
    && chgrp -R 0 /opt/hivemq/extensions/hivemq-prometheus-extension \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-prometheus-extension

COPY scripts/*.sh /opt/hivemq/bin/

# Move the entrypoint into the correct position & adjust for whether the base image uses entrypoint.d or not
#RUN chmod +x /opt/hivemq/bin/*.sh && \
#    if [ -d /docker-entrypoint.d ]; then \
#      mv /opt/hivemq/bin/pre-entry_1.sh /docker-entrypoint.d/15_k8s_entrypoint.sh && \
#      ln -s /opt/docker-entrypoint.sh /opt/hivemq/bin/pre-entry_1.sh; \
#    else \
#      echo '# Pass on to DNS entrypoint' >> /opt/hivemq/bin/pre-entry_1.sh && \
#      echo 'exec /opt/pre-entry.sh "$@"' >> /opt/hivemq/bin/pre-entry_1.sh; \
#    fi

COPY config.xml /opt/hivemq/conf/config.xml
COPY prometheusConfiguration.properties /opt/hivemq/extensions/hivemq-prometheus-extension/

#COPY --from=ext-builder /extensions/hivemq-k8s-sync-extension/target/hivemq-k8s-sync-extension /opt/hivemq/extensions/hivemq-k8s-sync-extension

# have to sacrifice layer efficiency due to https://github.com/moby/moby/issues/38710  and because COPY --chmod is still not really working/mainstream
#RUN chmod -R 775 /opt/hivemq/extensions/hivemq-k8s-sync-extension \
#    && chmod -R 775 /opt/hivemq/conf/config.xml


ENTRYPOINT ["/opt/hivemq/bin/pre-entry_1.sh"]
CMD ["/opt/hivemq/bin/run.sh"]
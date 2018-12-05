ARG TAG=latest
FROM hivemq4-base:${TAG}

# Use default DNS resolution timeout as default discovery interval
ENV HIVEMQ_DNS_DISCOVERY_INTERVAL 31
ENV HIVEMQ_DNS_DISCOVERY_TIMEOUT 30

# The default cluster transport bind port to use (UDP port)
ENV HIVEMQ_CLUSTER_PORT 8000
ENV HIVEMQ_WEB_UI_USER admin
ENV HIVEMQ_WEB_UI_PASSWORD a68fc32fc49fc4d04c63724a1f6d0c90442209c46dba6975774cde5e5149caf8

USER root

COPY config-dns.xml /opt/hivemq/conf/config.xml
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

RUN mkdir /opt/hivemq/plugins/hivemq4-dns-cluster-discovery
COPY hivemq4-dns-cluster-discovery/* /opt/hivemq/plugins/hivemq4-dns-cluster-discovery/

RUN chown -R hivemq:hivemq /opt/hivemq
RUN chmod +x /opt/docker-entrypoint.sh
USER hivemq

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["/opt/hivemq/bin/run.sh"]

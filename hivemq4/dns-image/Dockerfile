ARG BASEIMAGE=hivemq/hivemq4:latest

FROM ${BASEIMAGE}

# Use default DNS resolution timeout as default discovery interval
ENV HIVEMQ_DNS_DISCOVERY_INTERVAL 31
ENV HIVEMQ_DNS_DISCOVERY_TIMEOUT 30

# The default cluster transport bind port to use (UDP port)
ENV HIVEMQ_CLUSTER_PORT 8000
ENV HIVEMQ_CONTROL_CENTER_USER admin
ENV HIVEMQ_CONTROL_CENTER_PASSWORD a68fc32fc49fc4d04c63724a1f6d0c90442209c46dba6975774cde5e5149caf8

COPY config-dns.xml /opt/hivemq/conf/config.xml

RUN mkdir /opt/hivemq/extensions/hivemq-dns-cluster-discovery
COPY hivemq-dns-cluster-discovery/* /opt/hivemq/extensions/hivemq-dns-cluster-discovery/

RUN chown -R hivemq:hivemq /opt/hivemq
RUN chmod +x /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["/opt/hivemq/bin/run.sh"]

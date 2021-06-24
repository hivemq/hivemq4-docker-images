ARG BASEIMAGE=hivemq/hivemq4:latest

FROM ${BASEIMAGE}

# Use default DNS resolution timeout as default discovery interval
ENV HIVEMQ_DNS_DISCOVERY_INTERVAL 31
ENV HIVEMQ_DNS_DISCOVERY_TIMEOUT 30

# The default cluster transport bind port to use (UDP port)
ENV HIVEMQ_CLUSTER_PORT 8000
ENV HIVEMQ_CONTROL_CENTER_USER admin
ENV HIVEMQ_CONTROL_CENTER_PASSWORD a68fc32fc49fc4d04c63724a1f6d0c90442209c46dba6975774cde5e5149caf8
ENV HIVEMQ_CLUSTER_TRANSPORT_TYPE UDP

COPY config-dns.xml /opt/hivemq/conf/config.xml

RUN curl -L https://github.com/hivemq/hivemq-dns-cluster-discovery-extension/releases/download/4.1.0/hivemq-dns-cluster-discovery-4.1.0.zip -o /opt/hivemq/extensions/dns-discovery.zip \
    && unzip /opt/hivemq/extensions/dns-discovery.zip -d /opt/hivemq/extensions \
    && rm -f /opt/hivemq/extensions/hivemq-dns-cluster-discovery/*.png \
    && chmod -R 775 /opt/hivemq/extensions/hivemq-dns-cluster-discovery \
    && rm /opt/hivemq/extensions/dns-discovery.zip

COPY pre-entry.sh /opt/pre-entry.sh

RUN chmod +x /opt/docker-entrypoint.sh \
    && chmod +x /opt/pre-entry.sh

ENTRYPOINT ["/opt/pre-entry.sh"]
CMD ["/opt/hivemq/bin/run.sh"]

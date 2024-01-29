ARG BASEIMAGE=hivemq/hivemq4:latest

FROM ${BASEIMAGE}

ARG DNS_DISCOVERY_EXTENSION_VERSION=4.2.5

# Use default DNS resolution timeout as default discovery interval
ENV HIVEMQ_DNS_DISCOVERY_INTERVAL 31
ENV HIVEMQ_DNS_DISCOVERY_TIMEOUT 30

# The default cluster transport bind port to use (UDP port)
ENV HIVEMQ_CLUSTER_PORT 8000
ENV HIVEMQ_CONTROL_CENTER_USER admin
ENV HIVEMQ_CONTROL_CENTER_PASSWORD a68fc32fc49fc4d04c63724a1f6d0c90442209c46dba6975774cde5e5149caf8
ENV HIVEMQ_CLUSTER_TRANSPORT_TYPE UDP

COPY config.xml /opt/hivemq/conf/config.xml
COPY 40_dns_entrypoint.sh /docker-entrypoint.d/40_dns_entrypoint.sh

RUN curl -L https://github.com/hivemq/hivemq-dns-cluster-discovery-extension/releases/download/${DNS_DISCOVERY_EXTENSION_VERSION}/hivemq-dns-cluster-discovery-${DNS_DISCOVERY_EXTENSION_VERSION}.zip -o /tmp/hivemq-dns-cluster-discovery-extension.zip \
    && unzip /tmp/hivemq-dns-cluster-discovery-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-dns-cluster-discovery-extension.zip \
    && rm -f /opt/hivemq/extensions/hivemq-dns-cluster-discovery/*.png \
    && chgrp -R 0 /opt/hivemq/extensions/hivemq-dns-cluster-discovery \
    && chmod -R 770 /opt/hivemq/extensions/hivemq-dns-cluster-discovery \
    && chmod +x /docker-entrypoint.d/40_dns_entrypoint.sh

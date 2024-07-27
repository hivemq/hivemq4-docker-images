ARG BASEIMAGE=hivemq/hivemq4:latest


# Additional build image to unpack the zip files and change the permissions without retaining large layers just for those operations
FROM alpine:3.20@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5 AS unpack

ARG DNS_DISCOVERY_EXTENSION_VERSION=4.3.0

RUN mkdir -p /opt/hivemq/extensions

# Unpack hivemq-dns-cluster-discovery-extension
RUN apk --update add curl \
    && curl -L https://github.com/hivemq/hivemq-dns-cluster-discovery-extension/releases/download/${DNS_DISCOVERY_EXTENSION_VERSION}/hivemq-dns-cluster-discovery-${DNS_DISCOVERY_EXTENSION_VERSION}.zip -o /tmp/hivemq-dns-cluster-discovery-extension.zip \
    && unzip /tmp/hivemq-dns-cluster-discovery-extension.zip -d /opt/hivemq/extensions \
    && rm /tmp/hivemq-dns-cluster-discovery-extension.zip \
    && find /opt/hivemq/extensions/hivemq-dns-cluster-discovery -type d -print0 | xargs -0 chmod 750 \
    && find /opt/hivemq/extensions/hivemq-dns-cluster-discovery -type f -print0 | xargs -0 chmod 640 \
    # directories that need write permissions
    && chmod 770 /opt/hivemq/extensions/hivemq-dns-cluster-discovery \
    # files that need write permissions
    && chmod 660 /opt/hivemq/extensions/hivemq-dns-cluster-discovery/dnsdiscovery.properties \
    && chmod 660 /opt/hivemq/extensions/hivemq-dns-cluster-discovery/hivemq-extension.xml


# Actual image
FROM ${BASEIMAGE}

# Use default DNS resolution timeout as default discovery interval
ENV HIVEMQ_DNS_DISCOVERY_INTERVAL=31
ENV HIVEMQ_DNS_DISCOVERY_TIMEOUT=30

# The default cluster transport bind port to use (UDP port)
ENV HIVEMQ_CLUSTER_PORT=8000
ENV HIVEMQ_CONTROL_CENTER_USER=admin
ENV HIVEMQ_CONTROL_CENTER_PASSWORD=a68fc32fc49fc4d04c63724a1f6d0c90442209c46dba6975774cde5e5149caf8
ENV HIVEMQ_CLUSTER_TRANSPORT_TYPE=UDP

COPY --chmod=660 config.xml /opt/hivemq/conf/config.xml
COPY --chmod=755 40_dns_entrypoint.sh /docker-entrypoint.d/40_dns_entrypoint.sh
COPY --from=unpack /opt/hivemq/extensions/ /opt/hivemq/extensions/

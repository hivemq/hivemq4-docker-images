FROM openjdk:11-jre-slim

ARG HIVEMQ_VERSION=4.0.0
ENV HIVEMQ_GID=10000
ENV HIVEMQ_UID=10000

# Additional JVM options, may be overwritten by user
ENV JAVA_OPTS "-XX:+UnlockExperimentalVMOptions -XX:+UseNUMA"

# tini for proper signal propagation and a clean init
ENV TINI_VERSION v0.18.0

# gosu for root step-down to user-privileged process
ENV GOSU_VERSION 1.11

# Locale error fix, temporary
ENV LANG=en_US.UTF-8

# tini and gosu setup
RUN set -x \
        && apt-get update && apt-get install -y --no-install-recommends curl gpg-agent gpg dirmngr \
        && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini" -o /usr/local/bin/tini \
        && curl -fSL "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini.asc" -o /usr/local/bin/tini.asc \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" -o /usr/local/bin/gosu \
        && curl -fSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" -o /usr/local/bin/gosu.asc \
        && export GNUPGHOME="$(mktemp -d)" \
        && gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
        && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini \
        && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
        && rm -r "$GNUPGHOME" /usr/local/bin/tini.asc /usr/local/bin/gosu.asc \
        && { command -v gpgconf && gpgconf --kill all || :; } \
        && chmod +x /usr/local/bin/tini \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-get purge -y gpg dirmngr && rm -rf /var/lib/apt/lists/*

COPY config.xml /opt/config.xml
COPY logback.xml /opt/logback.xml
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

# HiveMQ setup
RUN curl https://hivemq.com/releases-all/hivemq-${HIVEMQ_VERSION}.zip -o /opt/hivemq-${HIVEMQ_VERSION}.zip \
    && unzip /opt/hivemq-${HIVEMQ_VERSION}.zip  -d /opt/\
    && rm -f /opt/hivemq-${HIVEMQ_VERSION}.zip \
    && ln -s /opt/hivemq-${HIVEMQ_VERSION} /opt/hivemq \
    && mv /opt/config.xml /opt/hivemq-${HIVEMQ_VERSION}/conf/config.xml \
    && mv /opt/logback.xml /opt/hivemq-${HIVEMQ_VERSION}/conf/logback.xml \
    && groupadd --gid ${HIVEMQ_GID} hivemq \
    && useradd -g hivemq -d /opt/hivemq -s /bin/bash --uid ${HIVEMQ_UID} hivemq \
    && chmod -R 775 /opt \
    && chmod +x /opt/hivemq/bin/run.sh /opt/docker-entrypoint.sh

# Substitute eval for exec and replace OOM flag if necessary (for older releases). This is necessary for proper signal propagation
RUN sed -i -e 's|eval \\"java\\" "$HOME_OPT" "$JAVA_OPTS" -jar "$JAR_PATH"|exec "java" $HOME_OPT $JAVA_OPTS -jar "$JAR_PATH"|' /opt/hivemq/bin/run.sh && \
    sed -i -e "s|-XX:OnOutOfMemoryError='sleep 5; kill -9 %p'|-XX:+CrashOnOutOfMemoryError|" /opt/hivemq/bin/run.sh

# Make broker data persistent throughout stop/start cycles
VOLUME /opt/hivemq/data

# Persist log data
VOLUME /opt/hivemq/log

#mqtt-clients
EXPOSE 1883

#HiveMQ Control Center
EXPOSE 8080

WORKDIR /opt/hivemq

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/opt/docker-entrypoint.sh"]
CMD ["/opt/hivemq/bin/run.sh"]
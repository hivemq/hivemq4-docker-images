ARG TAG=latest
FROM hivemq4-base:${TAG}

USER root

RUN mkdir /opt/hivemq/plugins/hivemq4-prometheus-monitoring-plugin
COPY hivemq4-prometheus-monitoring-plugin/* /opt/hivemq/plugins/hivemq4-prometheus-monitoring-plugin/

#prometheus port
EXPOSE 9399

RUN chown -R hivemq:hivemq /opt/hivemq
USER hivemq

CMD ["/opt/hivemq/bin/run.sh"]



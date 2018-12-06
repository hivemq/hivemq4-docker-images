ARG BASEIMAGE=hivemq/hivemq4:latest

FROM ${BASEIMAGE}

RUN mkdir /opt/hivemq/plugins/hivemq4-prometheus-monitoring-plugin
COPY hivemq4-prometheus-monitoring-plugin/* /opt/hivemq/plugins/hivemq4-prometheus-monitoring-plugin/

#prometheus port
EXPOSE 9399

RUN chown -R hivemq:hivemq /opt/hivemq

CMD ["/opt/hivemq/bin/run.sh"]
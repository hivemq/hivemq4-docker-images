== HiveMQ 4 Prometheus monitoring plugin
=== Type: Monitoring

=== Version: 1.0.0

=== License
The plugin comes with a Apache License see file://[LICENSE.txt]

=== Purpose
The Prometheus Monitoring plugin allows HiveMQ to expose metrics to a Prometheus application.

=== Configuration
The plugin can be configured with the prometheusConfiguration.properties file, which is part of the `hivemq4-prometheus-monitoring-plugin` folder
[cols="1m,1,2" options="header"]
.Configuration Options
|===
|Name
|Default
|Description

|port
|9399
|The port which the servlet will listen to

|host
|0.0.0.0
|The bind-address which the servlet will listen to

|metric_path
|/metrics
|The path for the service which gets called by Prometheus. It must start with a slash.

|===


=== Installation

1. Extract the zip file of the Prometheus monitoring plugin.
   The zip file contains a folder named `hivemq4-prometheus-monitoring-plugin`.
2. A configuration file `prometheusConfiguration.properties` can be found in the hivemq4-prometheus-monitoring-plugin folder
   The properties are preconfigured with standard settings and can be adapted to your needs (The meaning of the fields is explained below).
3. Move the complete folder `hivemq4-prometheus-monitoring-plugin` into the `[HIVEMQ-HOME]/plugins` folder of HiveMQ
4. Start HiveMQ.

==== Test
You can test your configuration by navigating to `<ip>:<port><metric_path>` (as configured in `prometheusConfiguration.properties`) in your browser.
For example the address would be http://localhost:9399/metrics with default values.

You should see data provided by the plugin:
----
# HELP com_hivemq_messages_incoming_publish_rate_total Generated from Dropwizard metric import (metric=com.hivemq.messages.incoming.publish.rate, type=com.codahale.metrics.Meter)
# TYPE com_hivemq_messages_incoming_publish_rate_total counter
com_hivemq_messages_incoming_publish_rate_total 0.0
...
----

[start=6]

6. Load and install Prometheus
7. Configure Prometheus to scrape from <ip>:<port>/servlet<metricPath> as configured in the prometheusConfiguration.properties.
8. Look at the website provided by your Prometheus application. You should be able to find the HiveMQ metrics.



=== Final Steps - Configuration of Prometheus

For detailed information please visit:  https://prometheus.io/docs/operating/configuration/

To enable Prometheus to gather metrics from HiveMQ, you need to add a scrape configuration to your Prometheus configuration.
The following is a minimal example using the default values of the plugin:

----
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'hivemq'
    scrape_interval: 5s
    metrics_path: '/metrics'
    static_configs:
      - targets: ['localhost:9399']





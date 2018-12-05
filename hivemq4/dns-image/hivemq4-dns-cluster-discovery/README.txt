= HiveMQ DNS discovery plugin

This plugin can be used with any cloud environment / container
orchestration environment that supports service discovery using a
https://en.wikipedia.org/wiki/Round-robin_DNS[round-robin] A record.

The following environment variables or property keys should be used to
customize the discovery parameters.

If a properties file is provided (`dnsdiscovery.properties` in `conf/`
folder), the plugin will use the key-value pairs from this file and
reload the values on file changes.

The plugin will attempt to load the properties file first. If it does not
exist, the plugin will not attempt to reload the properties and instead
try to read from the environment variables on each iteration until
broker shutdown.

*Configuration options:*

|=======================================================================
|Environment Variable |Default value |property key |Meaning
|HIVEMQ_DNS_DISCOVERY_ADDRESS |- |discoveryAddress |Address providing the A
record for the usage as cluster node addresses
|HIVEMQ_DNS_DISCOVERY_TIMEOUT |30 |resolutionTimeout |Wait time
for DNS resolution to complete
|=======================================================================

[[sample-dns-record]]
== Sample DNS record

The following list shows a sample round-robin A-record as expected and parsed by the
plugin:

....
$ dig tasks.hivemq        

; <<>> DiG 9.10.3-P4-Debian <<>> tasks.hivemq
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21767
;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;tasks.hivemq.          IN  A

;; ANSWER SECTION:
tasks.hivemq.       600 IN  A   10.0.0.6
tasks.hivemq.       600 IN  A   10.0.0.5
tasks.hivemq.       600 IN  A   10.0.0.4
tasks.hivemq.       600 IN  A   10.0.0.7
tasks.hivemq.       600 IN  A   10.0.0.3
....

This record represents a 5 node cluster on an overlay network.

[[how-it-works]]
== How it works

This diagram shows how DNS discovery is generally implemented on container engines.

The components differ when using DNS discovery outside of container engine.
When using it in conjunction with DNSaaS solutions for example, the DNS entries will be created by the orchestration solution used instead.

image::dns-discovery-diagram.png[DNS discovery visualized]

The container engine provides a DNS server to the containers/pods for improved caching of DNS queries as well as additional functionality like service discovery and hostnames for the containers.

This DNS server is the main endpoint the DNS discovery plugin will communicate with. The DNS server responds with a predefined record which is created by the orchestration engine.
The record contains the list of containers/pods in the cluster, which HiveMQ will then use to discover the other nodes.

[[usage]]
== Usage

Most container orchestration environments support this type of discovery. See the following list for some examples:

* https://kubernetes.io/docs/concepts/services-networking/service/#headless-services[Kubernetes]
* https://docs.docker.com/docker-cloud/apps/service-links/#discovering-containers-on-the-same-service-or-stack[Docker Swarm]
* https://mesosphere.github.io/mesos-dns/[Mesos]
* https://docs.openshift.com/container-platform/3.6/architecture/core_concepts/pods_and_services.html#headless-services[Openshift]

More information on using the discovery mechanisms listed above can be found in the https://github.com/hivemq/hivemq-docker-images#dns-discovery-image[DNS discovery image README]

To implement your own solution for this discovery method, you must either provide your HiveMQ deployment with

* a custom DNS record on your cloud provider's DNS service containing the addresses of your HiveMQ instances.
* an alternative DNS server included with the deployment, serving general DNS to the HiveMQ instances as well as providing a service discovery record.

=== Kubernetes

To use DNS discovery on Kubernetes, you will generally need a headless service pointing to the HiveMQ deployment, similar to the following configuration:

```
kind: Service
apiVersion: v1
metadata:
  name: hivemq-discovery
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  selector:
    app: hivemq-cluster1
  ports:
    - protocol: TCP
      port: 1883
      targetPort: 1883
  clusterIP: None
```

NOTE: The selector and name for the service are important. The selector defines which pods are listed in the resulting DNS record.

NOTE: The name will define the `service-name` of the resulting DNS record, which will be generally in the form of `<service-name>.<kubernetes-namespace>.svc.<dns-domain>`.

=== Docker Swarm

Docker swarm provides a DNS entry for service discovery by default. All you have to do is create a service, as shown in https://github.com/hivemq/hivemq-docker-images#docker-swarm[DNS discovery image README].
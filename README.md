
# Table of Contents
   
   * [What is HiveMQ?](#what-is-hivemq)
   * [HiveMQ Docker Images](#hivemq-docker-images)
        * [DNS discovery image](#dns-discovery-image)
            * [Building](#building)
            * [Usage](#usage)
                * [Docker Swarm](#docker-swarm)
                    * [Managing The Cluster](#managing-the-cluster)
                * [Kubernetes](#kubernetes)
                    * [Accessing the HiveMQ Control Center](#accessing-the-hivemq-control-center)
                    * [Accessing the MQTT port using external clients](#accessing-the-mqtt-port-using-external-clients)
                    * [Setting the HiveMQ Control Center username and password](#setting-the-hivemq-control-center-username-and-password)
                    * [Adding a license](#adding-a-license)
                    * [Overriding the bind address](#overriding-the-bind-address)
        * [HiveMQ base image](#hivemq-base-image)
   * [Tags](#tags)
   
# What is HiveMQ?

HiveMQ is a MQTT based messaging platform designed for the fast, efficient and reliable movement of data to and from connected IoT devices. It uses the MQTT protocol for instant, bi-directional push of data between your device and your enterprise systems. 
HiveMQ is built to address some of the key technical challenges organizations face when building new IoT applications, including:

* Building reliable and scalable business critical IoT applications
* Fast data delivery to meet the expectations of end users for responsive IoT products
* Lower cost of operation through efficient use of hardware, network and cloud resources
* Integrating IoT data into existing enterprise systems

While at its core, HiveMQ is an MQTT 3.1, MQTT 3.1.1 and MQTT 5.0 compliant MQTT broker, HiveMQ excels with its additional features designed for enterprise use cases and professional deployments.

See [Features](https://www.hivemq.com/features/) for more information.
   
# HiveMQ Docker images

This repository provides the `Dockerfile` and context for the images hosted in the [HiveMQ Docker Hub repository](https://hub.docker.com/r/hivemq/hivemq4/).

# DNS Discovery Image
The HiveMQ DNS discovery image comes with a DNS discovery extension.
It can be used with any container orchestration engine that supports service discovery using a round-robin A record.

A custom solution supplying the A record could be used as well.

The following environment variables should be used to customize the discovery and broker configuration respectively.

| Environment Variable | Default value | Meaning |
| :-------- | :----- | :-------------- |
| HIVEMQ_DNS_DISCOVERY_ADDRESS | - | Address to get the A record that will be used for cluster discovery |
| HIVEMQ_DNS_DISCOVERY_INTERVAL | 31 | Discovery interval in seconds |
| HIVEMQ_DNS_DISCOVERY_TIMEOUT | 30 | DNS resolution wait time in seconds |
| HIVEMQ_CLUSTER_PORT | 8000 | Port used for cluster transport |
| HIVEMQ_LICENSE | - | base64 encoded license file to use for the broker |
| HIVEMQ_BIND_ADDRESS | - | Set the *cluster transport* bind address, only necessary if the default policy (resolve hostname) fails |
| HIVEMQ_CONTROL_CENTER_USER | admin | Set the username for the HiveMQ Control Center login |
| HIVEMQ_CONTROL_CENTER_PASSWORD | SHA256 of `adminhivemq` (default) | Set the password hash for HiveMQ Control Center authentication |
| HIVEMQ_HIVEMQ_NO_ROOT_STEP_DOWN | - | Disable root privilege step-down at startup by setting this to `true`. See [HiveMQ base image](hivemq4/base-image) for more information. |

## Building

To build the image, you must first obtain the [HiveMQ DNS discovery](https://github.com/hivemq/hivemq-dns-cluster-discovery-extension) extension and copy the jar file to the `hivemq4/dns-image` folder.

The image can then be built by running `docker build -t hivemq-dns .` in the `hivemq4/dns-image` folder.

## Usage

Following are two examples, describing how to use this image on Docker Swarm and Kubernetes respectively.

Other environments (provided they support DNS discovery in some way) are compatible as well.

### Docker Swarm

*Please note that using Docker Swarm in production is not recommended.*

* Start a single node Swarm cluster by running:

```
docker swarm init
```
* Create an overlay network for the cluster nodes to communicate on: 

```
docker network create -d overlay --attachable myNetwork
```
* Create the HiveMQ service on the network

```
docker service create \
  --replicas 3 --network myNetwork \
  --env HIVEMQ_DNS_DISCOVERY_ADDRESS=tasks.hivemq \
  --publish target=1883,published=1883 \
  --publish target=8080,published=8080 \
  -p 8000:8000/udp \
  --name hivemq \
    hivemq/hivemq4:dns-latest
```

This will provide a 3 node cluster with the MQTT(1883) and HiveMQ Control Center(8080) ports forwarded to the host network.

This means you can connect MQTT clients on port 1883. The connection will be forwarded to any of the cluster nodes.

The HiveMQ HiveMQ Control Center can be used in a single node cluster. A sticky session for the HTTP requests in clusters with multiple nodes cannot be upheld with this configuration, as the internal load balancer forwards requests in an alternating fashion.
To use sticky sessions the Docker Swarm Enterprise version is required.


### Managing the cluster

To scale the cluster up to 5 nodes, run

```
docker service scale hivemq=5
```

To remove the cluster, run

```
docker service rm hivemq
```

To read the logs for all HiveMQ nodes in real time, use

```
docker service logs hivemq -f
```

To get the log for a single node, get the list of service containers using 

```
docker service ps hivemq
```

And print the log using

```
docker service logs <id>
```

where `<id>` is the container ID listed in the `service ps` command.

### Kubernetes

On Kubernetes, an appropriate deployment configuration is necessary to utilize DNS discovery.
A [headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services) will provide a DNS record for the broker that can be used for discovery.

Following is an example configuration for a HiveMQ cluster with 3 nodes using DNS discovery in a replication controller setup.

Please note that you may have to replace `HIVEMQ_DNS_DISCOVERY_ADDRESS` according to your Kubernetes namespace and configured domain.

```
apiVersion: v1
kind: ReplicationController
metadata:
  name: hivemq-replica
spec:
  replicas: 3
  selector:
    app: hivemq-cluster1
  template:
    metadata:
      name: hivemq-cluster1
      labels:
        app: hivemq-cluster1
    spec:
      containers:
      - name: hivemq-pods
        image: hivemq/hivemq4:dns-latest
        ports:
        - containerPort: 8080
          protocol: TCP
          name: hivemq-control-center
        - containerPort: 1883
          protocol: TCP
          name: mqtt
        env:
        - name: HIVEMQ_DNS_DISCOVERY_ADDRESS
          value: "hivemq-discovery.default.svc.cluster.local."
        - name: HIVEMQ_DNS_DISCOVERY_TIMEOUT
          value: "20"
        - name: HIVEMQ_DNS_DISCOVERY_INTERVAL
          value: "21"
        readinessProbe:
          tcpSocket:
            port: 1883
          initialDelaySeconds: 30
          periodSeconds: 60
          failureThreshold: 60
        livenessProbe:
          tcpSocket:
            port: 1883
          initialDelaySeconds: 30
          periodSeconds: 60
          failureThreshold: 60
---
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

#### Accessing the HiveMQ Control Center

To access the HiveMQ HiveMQ Control Center for a cluster running on Kubernetes, follow these steps:

* Create a service exposing the HiveMQ Control Center of the HiveMQ service. Use the following YAML definition:

```
kind: Service
apiVersion: v1
metadata:
  name: hivemq-hivemq-control-center
spec:
  selector:
    app: hivemq-cluster1
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  sessionAffinity: ClientIP
  type: LoadBalancer
```

* Create the service using `kubectl create -f web.yaml`

*Note that depending on your provider of Kubernetes environment, load balancers might not be available or additional configuration may be necessary to access the HiveMQ Control Center.*

#### Accessing the MQTT port using external clients

To allow access for the MQTT port of a cluster running on Kubernetes, follow these steps:

* Create a service exposing the MQTT port using a load balancer. You can use the following YAML definition:

```
kind: Service
apiVersion: v1
metadata:
  name: hivemq-mqtt
  annotations:
    service.spec.externalTrafficPolicy: Local
spec:
  selector:
    app: hivemq-cluster1
  ports:
    - protocol: TCP
      port: 1883
      targetPort: 1883
  type: LoadBalancer
```

Note that the `externalTrafficPolicy` annotation is necessary to allow the Kubernetes service to maintain a larger amount of concurrent connections.  
See [Source IP for Services](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-nodeport) for more information.

## Setting the HiveMQ Control Center username and password

The environment variable `HIVEMQ_CONTROL_CENTER_PASSWORD` allows you to set the password of the HiveMQ Control Center by defining a SHA256 hash for a custom password.
Additionally, you can also configure the username, using the environment variable `HIVEMQ_CONTROL_CENTER_USER`

See [Generate a SHA256 Password](https://www.hivemq.com/docs/hivemq/latest/#hivemqdocs_generate_sha256_password) to read more about how to generate the password hash.

## Adding a license

To use a license with this image, you must first encode it as a string.

To do so, run `cat license.lic | base64` (replace `license.lic` with the path to your license file).

Set the resulting string as the value for the `HIVEMQ_LICENSE` environment variable of the container.

## Overriding the bind address

By default this image will attempt to set the bind address using the containers `${HOSTNAME}` to ensure that HiveMQ will bind the cluster connection to the correct interface so a cluster can be formed.

This behavior can be overridden by setting any value for the environment variable `HIVEMQ_BIND_ADDRESS`. The broker will attempt to use the given value as the bind address instead.

# HiveMQ base image

The [HiveMQ base image](hivemq4/base-image) installs and optimizes the HiveMQ installation for execution as a container.

It is meant to be used to build custom images or to run a dockerized HiveMQ locally for testing purposes.

# Tags

The repository on the [HiveMQ Docker Hub repository](https://hub.docker.com/r/hivemq/hivemq4/) provides different versions of the HiveMQ image using tags:

| Tag | Meaning |
| :--- | :---  |
| latest | This tag will always point to the latest version of the [base image](#base-image) |
| dns-latest | This tag will always point to the latest version of the [DNS discovery image](#dns-discovery-image) | 
| `<version>` | Base image providing the given version of the broker (e.g. `4.0.0`) |
| dns-`<version>` | DNS discovery image based on the given version base image

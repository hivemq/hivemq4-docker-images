
# Table of Contents
   
* [What is HiveMQ?](#what-is-hivemq)
* [HiveMQ Docker Images](#hivemq-docker-images)
  * [HiveMQ Base Image](#hivemq-base-image)
  * [HiveMQ DNS Discovery Image](#hivemq-dns-discovery-image)
  * [Tags](#tags)
* [Basic Single Instance](#basic-single-instance)
* [Clustering](#clustering)
  * [Local Cluster with Docker Swarm](#local-cluster-with-docker-swarm)
    * [Managing the Cluster](#managing-the-cluster)
  * [Production Use with Kubernetes](#production-use-with-kubernetes)
    * [Accessing the HiveMQ Control Center](#accessing-the-hivemq-control-center)
    * [Accessing the MQTT Port Using External Clients](#accessing-the-mqtt-port-using-external-clients)
* [Configuration](#configuration)
  * [Setting the HiveMQ Control Center Username and Password](#setting-the-hivemq-control-center-username-and-password)
  * [Adding a License](#adding-a-license)
  * [Disabling the hivemq-allow-all-extension](#disabling-the-hivemq-allow-all-extension)
  * [Disabling Privilege Step-Down](#disabling-privilege-step-Down)
  * [Overriding the Cluster Bind Address](#overriding-the-cluster-bind-address)
  * [Setting the Cluster Transport Type](#setting-the-cluster-transport-type)
   
# What is HiveMQ?

HiveMQ is a MQTT based messaging platform designed for the fast, efficient and reliable movement of data to and from connected IoT devices. It uses the MQTT protocol for instant, bi-directional push of data between your device and your enterprise systems. 
HiveMQ is built to address some of the key technical challenges organizations face when building new IoT applications, including:

* Building reliable and scalable business critical IoT applications
* Fast data delivery to meet the expectations of end users for responsive IoT products
* Lower cost of operation through efficient use of hardware, network and cloud resources
* Integrating IoT data into existing enterprise systems

While at its core, HiveMQ is an MQTT 3.1, MQTT 3.1.1 and MQTT 5.0 compliant MQTT broker, HiveMQ excels with its additional features designed for enterprise use cases and professional deployments.

See [Features](https://www.hivemq.com/features/) for more information.
   
# HiveMQ Docker Images

This repository provides the `Dockerfile` and context for the images hosted in the [HiveMQ Docker Hub repository](https://hub.docker.com/r/hivemq/hivemq4/).

## HiveMQ Base Image

The [HiveMQ base image](hivemq4/base-image) installs and optimizes the HiveMQ installation for execution as a container.

It is meant to be used to build custom images or to run a dockerized HiveMQ locally for testing purposes.

## HiveMQ DNS Discovery Image

The [HiveMQ DNS discovery image](hivemq4/dns-image) is based on the HiveMQ base image and adds the [HiveMQ DNS Discovery Extension](https://www.hivemq.com/extension/dns-discovery-extension/).

We recommend using the HiveMQ DNS discovery image to run HiveMQ in a [cluster](#clustering).

### How to Build

To build the DNS discover image, you must first obtain the [HiveMQ DNS Discovery Extension](https://www.hivemq.com/extension/dns-discovery-extension/), unzip the file and copy the folder to the `hivemq4/dns-image` folder.

The image can then be built by running `docker build -t hivemq-dns .` in the `hivemq4/dns-image` folder.

## Tags

The [HiveMQ Docker Hub repository](https://hub.docker.com/r/hivemq/hivemq4/) provides different versions of the HiveMQ images using tags:

| Tag | Meaning |
| :--- | :---  |
| latest | This tag will always point to the latest version of the [HiveMQ base image](#hivemq-base-image) |
| dns-latest | This tag will always point to the latest version of the [HiveMQ DNS discovery image](#hivemq-dns-discovery-image) | 
| `<version>` | [Base image](#hivemq-base-image) providing the given version of the broker (e.g. `4.0.0`) |
| dns-`<version>` | [DNS discovery image](#hivemq-dns-discovery-image) based on the given version base image |

# Basic Single Instance

To start a single HiveMQ instance and allow access to the MQTT port as well as the Control Center, 
[get Docker](https://www.docker.com/get-started) and run the following command:

`docker run --ulimit nofile=500000:500000 -p 8080:8080 -p 8000:8000 -p 1883:1883 hivemq/hivemq4`

You can connect to the broker via MQTT (1883) or Websockets (8000) or the Control Center (8080) via the respective ports.

# Clustering

For running HiveMQ in a cluster, we recommend using the DNS discovery image.
This image has the [HiveMQ DNS Discovery Extension](https://www.hivemq.com/extension/dns-discovery-extension/) built in.
It can be used with any container orchestration engine that supports service discovery using a round-robin A record.

A custom solution supplying the A record could be used as well.

The following environment variables can be used to customize the discovery and broker configuration respectively.

| Environment Variable | Default value | Meaning |
| :-------- | :----- | :-------------- |
| HIVEMQ_DNS_DISCOVERY_ADDRESS | - | Address to get the A record that will be used for cluster discovery |
| HIVEMQ_DNS_DISCOVERY_INTERVAL | 31 | Interval in seconds after which to search for new nodes |
| HIVEMQ_DNS_DISCOVERY_TIMEOUT | 30 | How long to wait for DNS resolution to complete |
| HIVEMQ_CLUSTER_PORT | 8000 | Set the port to be used for the cluster transport |
| HIVEMQ_BIND_ADDRESS | - | Set the *cluster transport* bind address, only necessary if the default policy (resolve hostname) fails |
| HIVEMQ_CLUSTER_TRANSPORT_TYPE | UDP | Set the *cluster transport* type |
| HIVEMQ_LICENSE | - | base64 encoded license file to use for the broker |
| HIVEMQ_CONTROL_CENTER_USER | admin | Set the username for the HiveMQ Control Center login |
| HIVEMQ_CONTROL_CENTER_PASSWORD | SHA256 of `adminhivemq` (default) | Set the password hash for HiveMQ Control Center authentication |
| HIVEMQ_NO_ROOT_STEP_DOWN | - | Disable root privilege step-down at startup by setting this to `true`. See [HiveMQ base image](hivemq4/base-image) for more information. |
| HIVEMQ_ALLOW_ALL_CLIENTS | true | Whether the default packaged allow-all extension (starting from `4.3.0`) should be enabled or not. If this is set to false, the extension will be deleted prior to starting the broker. This flag is inactive for all versions prior to `4.3.0`. |
| HIVEMQ_REST_API_ENABLED | false | Whether the REST API (supported starting at `4.4.0`) should be enabled or not. If this is set to true, the REST API will bind to `0.0.0.0` on port `8888` at startup. This flag is unused for versions prior to `4.4.0`. |

Following are two examples, describing how to use this image on Docker Swarm and Kubernetes respectively.

Other environments are compatible as well (provided they support DNS discovery in some way).

## Local Cluster with Docker Swarm

To start a HiveMQ cluster locally, you can use Docker Swarm.

**Note:** Using Docker Swarm in production is not recommended.

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

This will provide a 3 node cluster with the MQTT (1883) and HiveMQ Control Center (8080) ports forwarded to the host network.

This means you can connect MQTT clients on port 1883. The connection will be forwarded to any of the cluster nodes.

The HiveMQ HiveMQ Control Center can be used in a single node cluster.
A sticky session for the HTTP requests in clusters with multiple nodes cannot be upheld with this configuration, as the internal load balancer forwards requests in an alternating fashion.
To use sticky sessions the Docker Swarm Enterprise version is required.

### Managing the Cluster

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

## Production Use with Kubernetes

NOTE: Please consider using the [Kubernetes Operator](https://www.hivemq.com/docs/operator/latest) instead, as it makes production deployment of HiveMQ much easier.

For production we recommend using the DNS discovery image in combination with Kubernetes.

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
        - name: HIVEMQ_CLUSTER_TRANSPORT_TYPE
          value: "TCP"
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

### Accessing the HiveMQ Control Center

To access the HiveMQ HiveMQ Control Center for a cluster running on Kubernetes, follow these steps:

* Create a service exposing the HiveMQ Control Center of the HiveMQ service. Use the following YAML definition (as `web.yaml`):

```
kind: Service
apiVersion: v1
metadata:
  name: hivemq-control-center
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

**Note:** Depending on your provider of Kubernetes environment, load balancers might not be available or additional configuration may be necessary to access the HiveMQ Control Center.

### Accessing the MQTT Port Using External Clients

To allow access for the MQTT port of a cluster running on Kubernetes, follow these steps:

* Create a service exposing the MQTT port using a load balancer. You can use the following YAML definition (as `mqtt.yaml`):

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

* Create the service using `kubectl create -f mqtt.yaml`

**Note:** The `externalTrafficPolicy` annotation is necessary to allow the Kubernetes service to maintain a larger amount of concurrent connections.  
See [Source IP for Services](https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-type-nodeport) for more information.

# Configuration

## Setting the HiveMQ Control Center Username and Password

The environment variable `HIVEMQ_CONTROL_CENTER_PASSWORD` allows you to set the password of the HiveMQ Control Center by defining a SHA256 hash for a custom password.

Additionally, you can also configure the username, using the environment variable `HIVEMQ_CONTROL_CENTER_USER`.

See [Generate a SHA256 Password](https://www.hivemq.com/docs/4/control-center/configuration.html#generate-password) to read more about how to generate the password hash.

## Adding a License

To use a license with a HiveMQ docker container, you must first encode it as a string.

To do so, run `cat license.lic | base64` (replace `license.lic` with the path to your license file).

Set the resulting string as the value for the `HIVEMQ_LICENSE` environment variable of the container.

## Disabling the hivemq-allow-all-extension

By default the HiveMQ docker images use the packaged `hivemq-allow-all-extension`.

This can be circumvented by setting the `HIVEMQ_ALLOW_ALL_CLIENTS` environment variable to `false`.

This will cause the entrypoint script to delete the extension on startup.

## Disabling Privilege Step-Down

By default the HiveMQ docker images check for root privileges at startup and, if present, switch to a less privileged user before running the HiveMQ broker.

This will enhance the security of the container.

If you wish to skip this step, set the environment variable `HIVEMQ_NO_ROOT_STEP_DOWN` to `false`.

## Overriding the Cluster Bind Address

By default the HiveMQ DNS discovery image attempts to set the bind address using the containers `${HOSTNAME}` to ensure that HiveMQ will bind the cluster connection to the correct interface so a cluster can be formed.

This behavior can be overridden by setting any value for the environment variable `HIVEMQ_BIND_ADDRESS`. The broker will attempt to use the given value as the bind address instead.

## Setting the Cluster Transport Type

By default the HiveMQ DNS discovery image uses UDP as transport protocol for the cluster transport.

If you would like to use TCP as transport type instead, you can set the `HIVEMQ_CLUSTER_TRANSPORT_TYPE` environment variable to `TCP`.

**Note:** We generally recommend using TCP for the cluster transport, as it makes HiveMQ less susceptible to network splits under high network load.

## Building a custom Docker image

See [our documentation](https://www.hivemq.com/docs/hivemq/latest/user-guide/docker.html#custom) for more information on how to build custom HiveMQ images.

# Contributing
If you want to contribute to HiveMQ 4 Docker Images, see the [contribution guidelines](CONTRIBUTING.md).

# License

HiveMQ 4 Docker Images is licensed under the `APACHE LICENSE, VERSION 2.0`. A copy of the license can be found [here](LICENSE).


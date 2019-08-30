# Running the image

## Basic single instance

To start a single HiveMQ instance and allow access to the MQTT port as well as the Web UI, 
[get Docker](https://www.docker.com/get-started) and run the following command:

`docker run --ulimit nofile=500000:500000 -p 8080:8080 -p 8000:8000 -p 1883:1883 hivemq/hivemq4`

You can connect to the broker via MQTT (1883) or Websockets (8000) or the WebUI (8080) via the respective ports.

## Run a cluster locally

For running HiveMQ with Docker in a cluster please refer to the [HiveMQ DNS discovery image](../../README.md).

## Disabling privilege step-down

By default, this image will check for root privileges at startup and, if present, switch to a less privileged user before running the HiveMQ broker.

This will enhance the security of the container.

If you wish to skip this step, set the environment variable `HIVEMQ_NO_ROOT_STEP_DOWN` to `false` to disable this step.

#!/bin/bash

set -e 

arch=$(uname -m)
ECHO "${arch}"

# Set the variables
ETCD_IMAGE_NAME="etcd_image"
ETCD_IMAGE_TAG="latest"
ETCD_DIR="./etcd_binaries"

# Build the container
ECHO "Starting the ETCD Container .."
docker build -t ${ETCD_IMAGE_NAME}:${ETCD_IMAGE_TAG} .
docker run -d ${ETCD_IMAGE_NAME}:${ETCD_IMAGE_TAG}

CONTAINER_ID=$(docker ps -a -q -n1)
echo "Container ID -> $CONTAINER_ID" 

# Copy the binaries to local directory
mkdir -p $ETCD_DIR
ECHO "Copying the ETCD and ETCDCTL binaries into the host machine"
docker cp ${CONTAINER_ID}:/go/bin/etcd ${ETCD_DIR}
docker cp ${CONTAINER_ID}:/go/bin/etcdctl ${ETCD_DIR}

# Push to the IBM ICR registry

if [[ -z "$artifactory_user" || -z "$artifactory_token" ]]; then
  echo "Artifactory credentials not provided. Exiting"
  exit 1
fi

ARTIFACTORY="https://na.artifactory.swg-devops.com/artifactory/hyc-cpd-skywalker-team-lakehouse-on-prem-docker-local/etcd"

# Push ETCD binary to Artifactory
if curl --fail -u "${artifactory_user}:${artifactory_token}" \
        --upload-file "${ETCD_DIR}/etcd" \
        "${ARTIFACTORY}/custom-etcd-v3.5.21-linux-${arch}"; then
        echo "Successfully pushed ETCD binary to ${ARTIFACTORY}/custom-etcd-v3.5.21-linux-${arch}"
else
        echo "Failed to push ETCD binary"
fi

# Upload ETCDCTL binary
if curl --fail -u "${artifactory_user}:${artifactory_token}" \
        --upload-file "${ETCD_DIR}/etcdctl" \
        "${ARTIFACTORY}/custom-etcdctl-v3.5.21-linux-${arch}"; then
        echo "Successfully pushed ETCDCTL binary to ${ARTIFACTORY}/custom-etcdctl-v3.5.21-linux-${arch}"
else
        echo "Failed to push ETCDCTL binary"
fi
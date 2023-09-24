#!/bin/bash
# set -x
set -e

IMAGE_NAME=failfr8er/sonarr
SONARR_RAW=$(curl -s https://services.sonarr.tv/v1/download/phantom-develop\?version\=3)
SONARR_ASSET=$(echo "${SONARR_RAW}" | jq -r '.linux.manual.url')
ALPINE_VERSION="latest"

[ -n "${1}" ] && export SONARR_ASSET="${SONARR_ASSET//$(echo $SONARR_RAW | jq -r '.version')/${1}}"

wget "${SONARR_ASSET}"
# Set Sonarr version
SONARR_VERSION=$(jq -r '.version' <<< "${SONARR_RAW}")
SONARR_VERSION_MAJOR="${SONARR_VERSION%%.*}"
SONARR_VERSION_MINOR="${SONARR_VERSION%.*.*}"

docker buildx build \
  --file Dockerfile \
  --cache-from=type=local,src=/tmp/.buildx \
  --cache-to=type=local,dest=/tmp/.buildx \
  --tag ${IMAGE_NAME}:latest \
  --tag ${IMAGE_NAME}:${SONARR_VERSION} \
  --tag ${IMAGE_NAME}:${SONARR_VERSION_MAJOR} \
  --tag ${IMAGE_NAME}:${SONARR_VERSION_MINOR} \
  --push \
  --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
  --build-arg SONARR_VERSION="${SONARR_VERSION}" \
  --platform=linux/amd64 \
  .

rm Sonarr.phantom-develop.*.linux.tar.gz
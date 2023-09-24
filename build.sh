#!/bin/bash
# set -x
set -e

IMAGE_NAME=failfr8er/sonarr
SONARR_RAW=$(curl -s https://services.sonarr.tv/v1/download/phantom-develop\?version\=3)
SONARR_VERSION=${1:-$(echo "${SONARR_RAW}" | jq -r '.version')}
SONARR_ASSET=$(echo "${SONARR_RAW}" | jq -r '.linux.manual.url')
ALPINE_VERSION="latest"

[ -n "${1}" ] && export SONARR_ASSET="${SONARR_ASSET//$(echo $SONARR_RAW | jq -r '.version')/${1}}"

wget "${SONARR_ASSET}"

docker buildx build \
  --file Dockerfile \
  --cache-from=type=local,src=/tmp/.buildx \
  --cache-to=type=local,dest=/tmp/.buildx \
  --tag ${IMAGE_NAME}:latest \
  --tag ${IMAGE_NAME}:3 \
  --tag ${IMAGE_NAME}:${SONARR_VERSION} \
  --push \
  --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
  --build-arg SONARR_VERSION="${SONARR_VERSION}" \
  --platform=linux/amd64 \
  .

rm Sonarr.phantom-develop.*.linux.tar.gz
#!/bin/bash
# set -x
set -e

ALPINE_VERSION="latest"
IMAGE_NAME="failfr8er/sonarr"

# Fetch Sonarr release information
SONARR_RAW=$(curl -s https://services.sonarr.tv/v1/download/main)

# Set Sonarr version
SONARR_VERSION=$(jq -r '.version' <<< "${SONARR_RAW}")
SONARR_VERSION_MAJOR="${SONARR_VERSION%%.*}"
SONARR_VERSION_MINOR="${SONARR_VERSION%.*.*}"

# Fetch Sonarr artifact
SONARR_ARTIFACT_URL=$(echo "${SONARR_RAW}" | jq -r '.linux.manual.url')
[[ -e "${SONARR_ARTIFACT_URL##*/}" ]] || wget "${SONARR_ARTIFACT_URL}"

# Output user relevant information
echo "Building: failfr8er/sonarr:${SONARR_VERSION}"
echo "Tags: ['latest', '${SONARR_VERSION}', '${SONARR_VERSION_MAJOR}', ${SONARR_VERSION_MINOR}']"

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

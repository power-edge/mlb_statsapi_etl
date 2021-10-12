#!/bin/bash

set -e

BUILD_VERSION=$1
BUILD_VERSION=${BUILD_VERSION:=0.1.0}

TAG_LATEST=$2
TAG_LATEST="${TAG_LATEST:=true}"

REPOSITORY_NAME="${REPOSITORY_NAME:=mlb-statsapi-etl}"

TAGS=(-t "$REPOSITORY_NAME:$BUILD_VERSION")

if [ "$TAG_LATEST" = "true" ]; then
  TAGS+=(
    -t "$REPOSITORY_NAME:latest"
  )
fi

echo "ALWAYS_RUN:" "$ALWAYS_RUN" docker build "${TAGS[@]}" .

docker build "${TAGS[@]}" .

#!/bin/bash

REPOSITORY_NAME="${REPOSITORY_NAME:=mlb-statsapi-etl}"

AWS_REGION="${AWS_REGION}"
AWS_ACCOUNT="${AWS_ACCOUNT}"

BUILD_VERSION=$1
BUILD_VERSION=${BUILD_VERSION:-0.1.0}

TAG_LATEST=$2
TAG_LATEST="${TAG_LATEST:-true}"

IMAGE="$REPOSITORY_NAME:$BUILD_VERSION"
DKR_ECR_TAG="$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE"

# main
aws ecr get-login-password \
  --region "$AWS_REGION" \
  | docker login \
  --username AWS \
  --password-stdin "${AWS_ACCOUNT}.dkr.ecr.$AWS_REGION.amazonaws.com"

docker tag "$IMAGE" "$DKR_ECR_TAG"
docker push "$DKR_ECR_TAG"

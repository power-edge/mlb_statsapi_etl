#!/bin/bash

set -e

ENV=$1

if [ "$ENV" = "" ]; then
  echo "You must pass the ENV. Got '$ENV'"
  exit 1
fi

terraform init \
 -backend-config="key=states/${ENV}.tfstate" \
 -backend-config="region=us-west-2"
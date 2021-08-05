#!/usr/bin/env bash

set -e

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
if [ ! "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" = "" ]; then
  AWS_CONTAINER_CREDENTIALS=$(curl "169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI")
  export AWS_CONTAINER_CREDENTIALS
fi


if [ "$1" = 'python' ]; then
    exec "$@"
fi

exec "$@"

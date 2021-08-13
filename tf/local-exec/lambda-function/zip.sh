#!/bin/bash

set -e

if [ "$ALWAYS_RUN" = "" ]; then
  echo "Please set the ALWAYS_RUN timestamp"
  exit 1
fi

if [ "$HANDLER_FILE" = "" ]; then
  echo "Please export a HANDLER_FILE to zip."
  echo "HANDLER_FILE should be relative to the ./src directory like './src/HANDLER_FILE'"
  exit 1
fi

FUNCTION=$1
if [ "$FUNCTION" = "" ]; then
  echo "Please pass a function name as arg1"
  exit 1
fi

BUILD=$2
BUILD="${BUILD:=latest}"
if [ "$BUILD" = "" ]; then
  echo "Please pass a build as arg2"
  exit 1
fi


getpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}


STAGE="./$FUNCTION"
ZIPFILE="./$BUILD-$ALWAYS_RUN.zip"


prep_stage(){
  if [ -d "$STAGE" ]; then
    rm -rf "$STAGE"
  fi
  mkdir -p "$STAGE"
}


remove_pycache(){
  find "$STAGE" | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
}


remove_non_lambda_handlers(){
  rm -rf "$STAGE/mlb_statsapi/cli.py"
  rm -rf "$STAGE/mlb_statsapi/apps"

  # remove directories that don't match
  export HF="$(echo "$HANDLER_FILE" | xargs dirname | cut -d "/" -f 2-)"
  export HANDLER_DIRECTORY="$STAGE/$HF"
  for stage_directory in $(find "$STAGE/mlb_statsapi/functions" -type d); do
    case "$HANDLER_DIRECTORY" in
    ("$stage_directory"*)
      ;;
    (*)
      rm -rf "$stage_directory"
      ;;
    esac
  done

  # remove files that don't match ( should be none left )
  find "$STAGE/mlb_statsapi/functions" \
    -type f \
    -not -name '__init__.py' \
    -not -name "$(basename "$HANDLER_FILE")" \
  | xargs rm -rf

}


copy_src(){
  cp -r ../../../src/mlb_statsapi "$STAGE/"
}


zip_lambda(){
  cd "$STAGE" && \
  zip -q -r "$ZIPFILE" mlb_statsapi* && \
  rm -rf mlb_statsapi* && \
  cd - || exit 1
}


cleanup(){
  rm -rf "$STAGE/src"
}


prep_stage
copy_src
remove_pycache
remove_non_lambda_handlers
zip_lambda
cleanup

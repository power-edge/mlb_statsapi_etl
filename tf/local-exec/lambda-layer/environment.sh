#!/bin/bash

LAYER_NAME="${LAYER_NAME:-mlb_statsapi}"

if [ ! -e ./environment.sh ]; then
  echo "please cd to the ./tf/local-exec/lambda-layer directory"
  exit 1
fi

set -e

clean_stage(){
  if [ -d "./$LAYER_NAME" ]; then
    rm -rf "./$LAYER_NAME"
  fi
}

create_environment(){
  if [ "$(python -m pip list | awk '{ print $1 }' | grep -c virtualenv)" -eq "0" ]; then
    # sudo apt-get install python3-venv
    sudo apt-get install python3-venv
    # make sure to have python 3.8 with virtualenv==20.7.2
    python -m pip install virtualenv==20.7.2
  fi
  python3 -m virtualenv --python="$(which python3.8)" "./$LAYER_NAME"
}

install_requirements(){
  . "./$LAYER_NAME/bin/activate"
  python3 -m pip install -r ./requirements.txt
  deactivate
}

clean_stage
create_environment
install_requirements

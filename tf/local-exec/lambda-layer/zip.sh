#!/bin/bash

LAYER_NAME="${LAYER_NAME:-mlb_statsapi}"

if [ "$ALWAYS_RUN" = "" ]; then
  echo "Please set the ALWAYS_RUN timestamp"
  exit 1
fi

getpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

ZIPFILE=$(getpath "./$LAYER_NAME-$ALWAYS_RUN.zip")

PYVERSION=$(python3.8 --version | awk '{print $2}' | cut -d "." -f 1-2)

SITE_PACKAGES="$LAYER_NAME/lib/python${PYVERSION}/site-packages"


prep_stage(){
  rm -rf "./$LAYER_NAME-"*
}


create_environment(){
  sh ./environment.sh
}


remove_pycache(){
  find "$SITE_PACKAGES" | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf
}


copy_configs_to_site_packages(){
  cp -r ../../../configs* "$SITE_PACKAGES"
}


zip_dependencies(){
  cd "$SITE_PACKAGES" && \
  zip -q -r "$ZIPFILE" \
    configs* \
    urllib3* \
    requests* \
    serde* \
    pytz* \
    yaml* \
    chardet* \
    certifi* \
    idna* \
    isodate* && \
  cd - || exit 1
}


cleanup(){
  rm -rf "$LAYER_NAME"
}

prep_stage
create_environment
remove_pycache
copy_configs_to_site_packages
zip_dependencies
cleanup
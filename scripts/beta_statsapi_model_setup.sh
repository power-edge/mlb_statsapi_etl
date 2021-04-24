#!/bin/bash

#set -x


API_VER=''
STATS_API_VER_PATH=''

BETA_STATSAPI_URL='https://beta-statsapi.mlb.com/api'

###########################################
# SEE https://beta-statsapi.mlb.com/docs/ #
###########################################

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
BASE_PATH=$(realpath "$SCRIPT_DIR/..")
MLB_STATSAPI_CONFIGS_PATH="$BASE_PATH/configs"

CONFIGS_PATH="$MLB_STATSAPI_CONFIGS_PATH/statsapi"
if [ ! -d "$CONFIGS_PATH" ]; then
    mkdir -p "$CONFIGS_PATH"
fi

get_url() {
    echo "$BETA_STATSAPI_URL/$1"
}

get_json() {
    case "$1" in
        *"$BETA_STATSAPI_URL"*) URL="$1" ;;
        *) URL=$(get_url "$1")
    esac
    curl -X GET -H "Content-Type: application/json" "$URL"
}

get_json_with_src() {
    SUBDIR=$1
    URL=$(get_url "$SUBDIR")
    get_json "$URL" | jq --arg src_url "$URL" '{ src_url: $src_url } + .'
}

get_md5sum() {
    md5sum "$1" | awk '{ print $1 }'
}

save_json_to_path() {
    json=$1
    path=$2
    dir_name=$(dirname "$path")
    if [ ! -d "$dir_name" ]; then
        mkdir -p "$dir_name"
    fi
    echo "$json" | jq '.' >> "$path"
}

check_md5sum() {
    check_path="$1"
    check_json=$2
    if [ -e "$check_path.tmp" ]; then
        rm "$check_path.tmp"
    fi
    save_json_to_path "$check_json" "$check_path.tmp"
    old_md5=$(get_md5sum "$check_path")
    tmp_md5=$(get_md5sum "$check_path.tmp")
    if [ ! "$old_md5" = "$tmp_md5" ]; then
        echo "ERROR: Found api json where (old != tmp) md5sum: ($old_md5 != $tmp_md5) from $check_path (see .tmp version)"
    else
        rm "$check_path.tmp"
    fi
}

save_with_md5sum() {
    save_wmd5_path="$1"
    save_wmd5_json=$2
    echo "save_with_md5sum: path=$save_wmd5_path"
    if [ -f "$save_wmd5_path" ]; then
        echo "file exists, checking md5sum: $save_wmd5_path"
        check_md5sum "$save_wmd5_path" "$save_wmd5_json"
    else
        echo "file not found, saving: $save_wmd5_path"
        save_json_to_path "$save_wmd5_json" "$save_wmd5_path"
    fi
}

save_api_docs() {
    api_docs=$(get_json_with_src 'api_docs')
    # determine api version
    API_VER=$(echo "$api_docs" | jq -r .apiVersion)
    APIS=$(echo "$api_docs" | jq -r '[ .apis[] | select( .path | test("authentication|-controller") | not ) ]')
    AUTH=$(echo "$api_docs" | jq -r .authorizations)
    INFO=$(echo "$api_docs" | jq -r .apiVersion)
    SWAG=$(echo "$api_docs" | jq -r .swaggerVersion)

    # create path to save by version
    STATS_API_VER_PATH="$CONFIGS_PATH/api_docs-$API_VER.json"

    API_DOCS=$(echo "{
      \"apiVersion\": $API_VER,
      \"apis\": $APIS,
      \"authorizations\": $AUTH,
      \"info\": $INFO,
      \"swaggerVersion\": $SWAG
    }" | jq \
    --arg url https://statsapi.mlb.com/api \
    --arg api_doc $BETA_STATSAPI_URL \
    '{
      api_doc: $api_doc,
      url: $url
     } + .')

    # This api_docs.json contains all the metadata about the rest of the endpoints
    save_with_md5sum "$STATS_API_VER_PATH" "$API_DOCS"
}

set_api_version_info() {
    # determine api version
    if [ -z "$API_VER" ]; then
        echo "API_VER NOT SET, GETTING FROM $BETA_STATSAPI_URL"
        API_VER=$(get_json "$api_docs" | jq -r .apiVersion)
    fi
    if [ -z "$STATS_API_VER_PATH" ]; then
        # create path to save by version
        echo "STATS_API_VER_PATH NOT SET, GETTING FROM $API_VER"
        STATS_API_VER_PATH="$CONFIGS_PATH/api_docs-$API_VER.json"
    fi
}

save_api_by_path() {
    save_api_path=$1
    echo "save_api_by_path: $save_api_path"
    # shellcheck disable=SC2001
    api_name="$(echo "$save_api_path" | sed "s/stats-api/stats-api-$API_VER/g")"
    api_doc=$(get_json_with_src "api_docs/$save_api_path"  | jq \
        --arg api_path "$save_api_path" \
        --arg API_VER "$API_VER" \
        '{ api_path: $api_path, apiVersion: $API_VER } + .')
    save_with_md5sum "$CONFIGS_PATH/$api_name.json" "$api_doc"
}

save_api_docs
set_api_version_info
for api_path in $(<"$STATS_API_VER_PATH" jq -r '.apis[].path[1:]'); do
    save_api_by_path "$api_path"
done

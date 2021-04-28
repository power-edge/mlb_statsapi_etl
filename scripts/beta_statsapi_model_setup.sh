#!/bin/bash

set -e

DEFAULT_API_VER='1.0'
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
    chmod 444 "$path"
}

check_md5sum() {
    check_path="$1"
    check_json=$2
    tmp_path="$(echo "$check_path" | sed 's/\.json$/\.tmp\.json/g')"
    if [ -e "$tmp_path" ]; then
        rm -f "$tmp_path"
    fi
    save_json_to_path "$check_json" "$tmp_path"
    old_md5=$(get_md5sum "$check_path")
    tmp_md5=$(get_md5sum "$tmp_path")
    if [ ! "$old_md5" = "$tmp_md5" ]; then
        echo "ERROR: Found api json where md5sum old != tmp: ($old_md5 != $tmp_md5) from $check_path (see .tmp version)"
        exit 1
    else
        rm -f "$tmp_path"
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
    echo "FOUND API_VER: \"$API_VER\""
    APIS=$(echo "$api_docs" | jq -r '[ .apis[] | select( .path | test("authentication|-controller") | not ) ]')
    AUTH=$(echo "$api_docs" | jq -r .authorizations)
    INFO=$(echo "$api_docs" | jq -r .apiVersion)
    SWAG=$(echo "$api_docs" | jq -r .swaggerVersion)
    SRC_URL=$(echo "$api_docs" | jq .src_url)

    echo "SRC_URL: $SRC_URL"

    # create path to save by version
    STATS_API_VER_PATH="$CONFIGS_PATH/api_docs-$API_VER.json"

    API_DOCS=$(echo "{
      \"apiVersion\": \"$API_VER\",
      \"apis\": $APIS,
      \"authorizations\": $AUTH,
      \"info\": $INFO,
      \"swaggerVersion\": \"$SWAG\",
      \"src_url\": $SRC_URL
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
#        echo "API_VER NOT SET, GETTING FROM $BETA_STATSAPI_URL"
#        API_VER=$(get_json "api_docs" | jq -r .apiVersion)
        echo "API_VER NOT SET, USING DEFAULT: $DEFAULT_API_VER"
        API_VER="$DEFAULT_API_VER"
        echo "API_VER SET: $API_VER"
    fi
    if [ -z "$STATS_API_VER_PATH" ]; then
        # create path to save by version
        echo "STATS_API_VER_PATH NOT SET, GETTING FROM API_VER: $API_VER"
        STATS_API_VER_PATH="$CONFIGS_PATH/api_docs-$API_VER.json"
        echo "STATS_API_VER_PATH SET: $STATS_API_VER_PATH"
    fi
}

add_awards_to_config_doc() {
    config_doc="$1"
    echo "$config_doc" | jq -r "{
        apiVersion: .apiVersion,
        api_path: .api_path,
        apis: (.apis + [{
            description: \"awards\",
            path: \"/v1/awards\",
            operations: [{
                consumes: [\"application/json\"],
                deprecated: \"false\",
                items: { type: \"AwardsTypeRestObject\" },
                method: \"GET\",
                nickname: \"awards\",
                notes: \"awards\",
                parameters: [],
                produces: [ \"*/*\" ],
                responseMessages: [
                    { code: 200, message: \"OK\", responseModel: \"array\"},
                    { code: 401, message: \"Unauthorized\" },
                    { code: 403, message: \"Forbidden\" },
                    { code: 404, message: \"Not Found\" }
                ],
                summary: \"List all awards\",
                type: \"array\",
                uniqueItems: false
            }],
        }]),
        basePath: .basePath,
        consumes: .consumes,
        models: .models,
        produces: .produces,
        resourcePath: .resourcePath,
        src_url: .src_url,
        swaggerVersion: .swaggerVersion,
    }"
}

filter_duplicate_api_models_from_draft() {
    draft_doc="$1"
    echo "$draft_doc" | jq -r "{
        apiVersion: .apiVersion,
        api_path: .api_path,
        apis: [(.apis[] | select( .path | test(\"/v1/draft/prospects$\") | not ))],
        basePath: .basePath,
        consumes: .consumes,
        models: .models,
        produces: .produces,
        resourcePath: .resourcePath,
        src_url: .src_url,
        swaggerVersion: .swaggerVersion,
    }"
}

save_api_by_path() {
    save_api_path=$1
    echo "save_api_by_path: $save_api_path"
    # shellcheck disable=SC2001
    api_name="$(echo "$save_api_path" | sed "s/stats-api/stats-api-$API_VER/g")"
    api_doc=$(get_json_with_src "api_docs/$save_api_path"  | jq \
        --arg api_path "$save_api_path" \
        --arg API_VER "$API_VER" \
        '{ api_path: $api_path, apiVersion: "$API_VER" } + .')

    if [ "$save_api_path" = 'stats-api/config' ]; then
        api_doc="$(add_awards_to_config_doc "$api_doc")"
    elif [ "$save_api_path" = "stats-api/draft" ]; then
        api_doc="$(filter_duplicate_api_models_from_draft "$api_doc")"
    fi
    save_with_md5sum "$CONFIGS_PATH/$api_name.json" "$api_doc"
}


##############
#### MAIN ####
##############

save_api_docs
set_api_version_info
for api_path in $(<"$STATS_API_VER_PATH" jq -r '.apis[].path[1:]'); do
    save_api_by_path "$api_path"
    sleep 1
done

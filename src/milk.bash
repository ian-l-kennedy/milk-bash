#!/usr/bin/env bash

#
# This file is part of the milk-bash project.
#
# Copyright (C) 2024 Ian Lindsay Kennedy
#
# Author(s): Ian Lindsay Kennedy
# Attribution: This code was originally authored by Ian Lindsay Kennedy.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

export LOGFILE=/tmp/bash_logger.log
export LOG_FORMAT='%DATE PID:%PID %SNAME%LINE%FNAME: [%LEVEL]: %MESSAGE'
export LOG_DATE_FORMAT='+%T %Z'                     # Example: 21:51:57 EST
export LOG_COLOR_DEBUG="\033[0;37m"                 # Gray
export LOG_COLOR_INFO="\033[0m"                     # White
export LOG_COLOR_NOTICE="\033[1;32m"                # Green
export LOG_COLOR_WARNING="\033[1;33m"               # Yellow
export LOG_COLOR_ERROR="\033[1;31m"                 # Red
export LOG_COLOR_CRITICAL="\033[44m"                # Blue Background
export LOG_COLOR_ALERT="\033[43m"                   # Yellow Background
export LOG_COLOR_EMERGENCY="\033[41m"               # Red Background
export RESET_COLOR="\x1b[0m"                        # Clear Colors

function DEBUG() {
    if ! [ -z "${ENABLE_BASH_LOGGER_DEBUG:-}" ]; then
        LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"
    fi
}

function INFO() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function NOTICE() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function WARNING() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function ERROR() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function CRITICAL() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function ALERT() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }
function EMERGENCY() { LOG_HANDLER_DEFAULT "$FUNCNAME" "$@"; }

# Outputs a log formatted using the LOG_FORMAT and DATE_FORMAT configurables
# Usage: FORMAT_LOG <log level> <log message>
# Example: FORMAT_LOG CRITICAL "My critical log"
function FORMAT_LOG() {
    local level="$1"
    local log="$2"
    local pid=$$
    local date="$(date "$LOG_DATE_FORMAT")"

    local script_name_init_full="${BASH_SOURCE[3]}"
    local script_name_init="${script_name_init_full##*/}"
    local script_name=${script_name_init}
    if [[ $script_name_init == "" ]] ; then script_name=terminal ; fi
    local func_name=" ${FUNCNAME[3]}"
    if [[ $script_name_init == "" ]] ; then func_name="" ; fi
    local line_number=" ${BASH_LINENO[2]}"
    if [[ $script_name_init == "" ]] ; then line_number="" ; fi

    local formatted_log="$LOG_FORMAT"
    formatted_log="${formatted_log/'%MESSAGE'/$log}"
    formatted_log="${formatted_log/'%LEVEL'/$level}"
    formatted_log="${formatted_log/'%PID'/$pid}"
    formatted_log="${formatted_log/'%LINE'/$line_number}"
    formatted_log="${formatted_log/'%FNAME'/$func_name}"
    formatted_log="${formatted_log/'%SNAME'/$script_name}"
    formatted_log="${formatted_log/'%DATE'/$date}"
    echo "$formatted_log\n"
}

# All log levels call this handler
# logging behavior
# Usage: LOG_HANDLER_DEFAULT <log level> <log message>
# Example: LOG_HANDLER_DEFAULT DEBUG "My debug log"
function LOG_HANDLER_DEFAULT() {
    # $1 - level
    # $2 - message
    local formatted_log="$(FORMAT_LOG "$@")"
    LOG_HANDLER_COLORTERM "$1" "$formatted_log"
    LOG_HANDLER_LOGFILE "$1" "$formatted_log"
}

# Outputs a log to the stdout, colourised using the LOG_COLOR configurables
# Usage: LOG_HANDLER_COLORTERM <log level> <log message>
# Example: LOG_HANDLER_COLORTERM CRITICAL "My critical log"
function LOG_HANDLER_COLORTERM() {
    local level="$1"
    local log="$2"
    local color_variable="LOG_COLOR_$level"
    local color="${!color_variable}"
    log="$color$log$RESET_COLOR"
    echo -en "$log"
}

# Appends a log to the configured logfile
# Usage: LOG_HANDLER_LOGFILE <log level> <log message>
# Example: LOG_HANDLER_LOGFILE NOTICE "My critical log"
function LOG_HANDLER_LOGFILE() {
    local level="$1"
    local log="$2"
    local log_path="$(dirname "$LOGFILE")"
    [ -d "$log_path" ] || mkdir -p "$log_path"
    echo "$log" >> "$LOGFILE"
}

function REQUIRE_COMMAND () {
    if [ -z "${1}" ] ; then
        ERROR "No command specified. A command is required."
        exit 1
    fi

    if ! [ -x "$(command -v ${1})" ] ; then
        ERROR "'${1}' is required, but '${1}' is not found on PATH."
        exit 1
    fi
}

function REQUIRE_AS_USER () {
    if [[ $EUID -eq 0 ]] ; then
        ERROR "This script was not deisgned to run as ROOT."
        exit 1
    fi
}

function REQUIRE_VARIABLE () {
    local var_name="$1"
    # Using indirect expansion to get the value of the variable by its name
    local var_value="${!var_name}"

    if [[ -z "${var_value}" ]] ; then
        ERROR "Variable ${var_name} is required, but it is not set in your environment."
        exit 1
    fi
}

function REQUIRE_IN_GIT () {
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 ; then
        WARNING "The current directory is not part of a git repository."
        ERROR "Required to be inside repository."
        exit 1
    fi
}

function REQUIRE_GIT_HOOKS () {
    repo="${1}"
    repo_n=$(basename ${repo})
    cd ${repo}
    REQUIRE_IN_GIT
    git config --local include.path "${repo}/.gitconfig"
    my_check=$(grep -c "${repo_n}/\.gitconfig" "${repo}/.git/config")
    if [[ $my_check -eq 0 ]]; then
        ERROR "Failed to initialize and install the git hooks"
        exit 1
    fi
    # Path to the custom hooks directory and the Git hooks directory
    custom_hooks_dir="${repo}/.githooks"
    git_hooks_dir="${repo}/.git/hooks"

    # Ensure the custom hooks directory exists
    if [[ ! -d $custom_hooks_dir ]]; then
        echo "No custom hooks directory found."
        exit 1
    fi

    # Install or verify hooks
    for hook in "$custom_hooks_dir"/*; do
        hook_name=$(basename "$hook")
        if [[ -x "$hook" ]] && [[ ! -e "${git_hooks_dir}/${hook_name}" ]]; then
            echo "Installed $hook_name"
        elif [[ -e "${git_hooks_dir}/${hook_name}" ]]; then
            echo "$hook_name is already installed."
        else
            echo "Could not install $hook_name, please check permissions."
            exit 1
        fi
    done

    echo "All hooks checked and installed where necessary."
}

function BASH_EVALUATED_JSON() {
    local input_file_path=$1
    local json_compact
    local key
    local value
    local value_type
    local first_item=true

    if [ -z "$input_file_path" ]; then
        ERROR "Input JSON file path is required."
        return 1
    fi

    local is_test=false
    if [[ " $* " =~ " IS_TEST " ]]; then
        is_test=true
        DEBUG "Input File Contents:"
        DEBUG "$(cat "$input_file_path")"
    fi

    json_compact=$(jq -Scr '.' "$input_file_path")
    if [ $? -ne 0 ]; then
        ERROR "Error in jq compacting JSON."
        return 1
    fi

    if $is_test; then
        DEBUG "Valid JSON input contents:"
        DEBUG "$(jq -Scr '.' "$input_file_path")"
    fi

    readarray -t items_array < <(jq -Scr 'to_entries | .[]' "$input_file_path")
    if [ $? -ne 0 ]; then
        ERROR "Error in jq reading JSON to_entries as array."
        return 1
    fi

    if $is_test; then
        DEBUG "items_array from to_entries: ${items_array[@]}"
    fi

    echo '{'

    for item in "${items_array[@]}"; do
        key=$(jq -r '.key' <<< "$item")
        value=$(jq -r '.value' <<< "$item")
        value_type=$(jq -r '.value | type' <<< "$item")

        if $is_test; then
            DEBUG "key: ${key}"
            DEBUG "value: ${value}"
            DEBUG "value_type: ${value_type}"
        fi

        if [[ "$value_type" == "boolean" || "$value_type" == "number" ]]; then
            ERROR "Boolean and integer types are not supported. Key: '$key'"
            return 1
        fi

        if [ "$first_item" = true ]; then
            first_item=false
        else
            echo ','
        fi

        if [[ "$value_type" == "object" ]]; then
            ERROR "Nested JSON Objects are not supported"
            return 1
        elif [[ "$value_type" == "array" ]]; then
            if jq -e '.[]. | arrays, objects' <<< "$value" >/dev/null; then
                ERROR "Nested arrays and nested objects are not supported. Key: '$key'"
                return 1
            fi

            echo -n "\"$key\":["
            local array_first_item=true
            readarray -t array_items < <(jq -c '.[]' <<< "$value")

            for array_item in "${array_items[@]}"; do
                item_type=$(jq -r 'type' <<< "$array_item")
                if [ "$item_type" != "string" ]; then
                    ERROR "Only string values are allowed in arrays. Key: '$key'"
                    return 1
                fi

                if [ "$array_first_item" = true ]; then
                    array_first_item=false
                else
                    echo -n ','
                fi

                if $is_test; then
                    DEBUG "Evaluating array item: $array_item"
                fi

                evaluated_value=$(eval echo "$array_item" | jq -R .)
                if [ $? -ne 0 ]; then
                    ERROR "Error in evaluating array item."
                    return 1
                fi
                echo -n "$evaluated_value"
            done
            echo -n ']'
        else
            if $is_test; then
                DEBUG "Evaluating value: $value"
            fi

            if echo "$value" | egrep -q '\\[^"]'; then
                ERROR "Only escaped double quotes (\\\") are allowed. Key: '$key'"
                return 1
            fi

            evaluated_value=$(eval echo "$value")
            if [ $? -ne 0 ]; then
                ERROR "Error in evaluating value."
                return 1
            fi
            echo "\"$key\":\"$evaluated_value\""
        fi
    done
    echo '}'
    return 0
}

function BASH_EVALUATED_YAML() {
    local input_file_path=$1
    local key
    local value
    local value_type
    local first_item=true

    if [ -z "$input_file_path" ]; then
        ERROR "Input YAML file path is required."
        return 1
    fi

    if [ ! -s "$input_file_path" ]; then
        echo ""
        return 0
    fi

    local is_test=false
    if [[ " $* " =~ " IS_TEST " ]]; then
        is_test=true
        DEBUG "Input File Contents:"
        echo "$(cat "$input_file_path")"
    fi

    yq '.' "$input_file_path" &> /dev/null
    if [ $? -ne 0 ]; then
        ERROR "Error in yq processing YAML."
        return 1
    fi

    local yq_output
    yq_output=$(yq eval '. | keys | .[]' "$input_file_path")
    if [ $? -ne 0 ]; then
        ERROR "Error in yq reading YAML keys as array."
        return 1
    fi

    readarray -t keys_array < <(yq eval '. | keys | .[]' "$input_file_path")
    if [ $? -ne 0 ]; then
        ERROR "Error in yq reading YAML keys as array."
        return 1
    fi

    if $is_test; then
        DEBUG "keys_array from keys: ${keys_array[*]}"
    fi

    for key in "${keys_array[@]}"; do
        if [[ "$key" =~ \\ ]]; then
            ERROR "Escaped characters are not allowed in keys."
            return 1
        fi

        value=$(yq eval ".\"$key\"" "$input_file_path")
        value_type=$(yq eval ".\"$key\" | type" "$input_file_path")

        if $is_test; then
            DEBUG "key: ${key}"
            DEBUG "value: ${value}"
            DEBUG "value_type: ${value_type}"
        fi

        if [ "$value_type" == "!!str" ]; then
            value=$(echo "$value" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
        fi

        if [[ "$value" =~ \\ && ! "$value" =~ \\$ && ! "$value" =~ \\\" ]]; then
            ERROR "Escaped characters other than \$ and \" are not allowed."
            return 1
        fi

        if [[ "$value" =~ \\[tnr] ]]; then
            ERROR "Escaped whitespace characters (\\t, \\n, \\r) are not allowed."
            return 1
        fi

        if [ "$first_item" = true ]; then
            first_item=false
        else
            echo -e '\n'
        fi

        if [[ "$value_type" == "!!bool" || "$value_type" == "!!int" || "$value_type" == "!!float" ]]; then
            ERROR "Boolean, integer, and float types are not supported. Key: '$key'. Type: '$value_type'"
            return 1
        elif [[ "$value_type" == "!!map" ]]; then
            ERROR "Nested YAML Objects/Maps are not supported"
            return 1
        elif [[ "$value_type" == "!!seq" ]]; then
            echo "$key:"
            readarray -t parsed_items_array < <(echo "${value}" | yq eval '. | .[]')
            if [ $? -ne 0 ]; then
                ERROR "parsed_items_array: Error in yq reading YAML keys as array."
                return 1
            fi

            if $is_test; then
                DEBUG "parsed_items_array from keys: ${parsed_items_array[*]}"
            fi

            for array_item in "${parsed_items_array[@]}"; do
                parsed_seq_value=$array_item
                parsed_seq_value_type=$(yq eval 'type' <<< "$array_item")

                if $is_test; then
                    DEBUG "parsed_seq_value: ${parsed_seq_value}"
                    DEBUG "parsed_seq_value_type: ${parsed_seq_value_type}"
                fi

                if [[ "$parsed_seq_value_type" == "!!bool" || "$parsed_seq_value_type" == "!!int" || "$parsed_seq_value_type" == "!!float" || "$parsed_seq_value_type" == "!!map" || "$parsed_seq_value_type" == "!!seq" ]]; then
                    ERROR "We are already in a sequence/array, so the only allowed type is !!str. Instead type is: $parsed_seq_value_type"
                    return 1
                fi

                if [ "$parsed_seq_value_type" == "!!str" ]; then
                    parsed_seq_value=$(echo "$parsed_seq_value" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
                fi

                if [[ "$parsed_seq_value" =~ \\ && ! "$parsed_seq_value" =~ \\$ && ! "$parsed_seq_value" =~ \\\" ]]; then
                    ERROR "Escaped characters other than \$ and \" are not allowed."
                    return 1
                fi

                if [[ "$parsed_seq_value" =~ \\[tnr] ]]; then
                    ERROR "Escaped whitespace characters (\\t, \\n, \\r) are not allowed."
                    return 1
                fi

                if $is_test; then
                    DEBUG "Inside sequence/array item - evaluating value: $parsed_seq_value"
                fi

                evaluated_value=$(eval echo "$parsed_seq_value")
                if [ $? -ne 0 ]; then
                    ERROR "Error in evaluating value."
                    return 1
                fi
                echo "  - $evaluated_value"
            done
        else
            if $is_test; then
                DEBUG "Evaluating value: $value"
            fi

            evaluated_value=$(eval echo "$value")
            if [ $? -ne 0 ]; then
                ERROR "Error in evaluating value."
                return 1
            fi
            echo "$key: $evaluated_value"
        fi
    done
    return 0
}

# Only if inside of a git repository, set REPO and REPO_N
git rev-parse --is-inside-work-tree >/dev/null 2>&1
if [[ $? -eq 0 ]]; then
    REPO=$(git rev-parse --show-toplevel)
    REPO_N=$(basename "$REPO")
fi

# milk standard versioning of a project for artifact publication
function GET_VERSION_NUMBER_JSON () {
    REQUIRE_COMMAND "jq"
    REQUIRE_COMMAND "git"
    if [ -n "${1:-}" ]; then
        current_branch="$1"
    else
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ $? -ne 0 ]; then
            ERROR "Failed to determine the current git branch."
            exit 1
        fi
    fi

    file_name=${REPO}/version.json

    if [ ! -f "${file_name}" ]; then
        ERROR "The version.json file does not exist at the top of the current git repository"
        exit 1
    fi

    version_from_file_major=$(cat "$file_name" | jq -rc '.major')
    version_from_file_minor=$(cat "$file_name" | jq -rc '.minor')
    version_from_file_patch=$(cat "$file_name" | jq -rc '.patch')

    num_seconds_in_ten_minutes_timespan=600

    version_from_epoch_major=0
    version_from_epoch_minor=0
    version_from_epoch_patch=$(echo $(($(date +%s) / num_seconds_in_ten_minutes_timespan)))

    if [ $? -ne 0 ]; then
        ERROR "Failed to calculate the EPOCH seconds divided by 10 minutes timespan in seconds"
        exit 1
    fi

    if [ "${current_branch}" == "main" ]; then
        echo "${version_from_file_major}.${version_from_file_minor}.${version_from_file_patch}"
    else
        echo "${version_from_epoch_major}.${version_from_epoch_minor}.${version_from_epoch_patch}"
    fi
}

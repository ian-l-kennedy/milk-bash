#!/usr/bin/env bats

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

function test_init () {
    set -e
    source $(git rev-parse --show-toplevel)/src/milk.bash
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    REQUIRE_COMMAND bash
    REQUIRE_COMMAND jq
    input_file=input.json
    expects_file=expects.json
    rm -f ${input_file}
    rm -f ${expects_file}
}

function test_exit () {
    rm -f ${input_file}
    rm -f ${expects_file}
}

function test_print_stim () {
    # Print input test stimulus
    echo "Test input stimulus:"
    jq -S . ${1}
    echo ""
}

function test_print_exp () {
    # Print output expects
    echo "Test output expects:"
    jq -S . ${1}
    echo ""
}

function test_print_obs () {
    # Print output observes
    echo "Test output observes:"
    echo "$1" | jq -S .
    echo ""
}

@test "test_valid_input" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"value1","key2":"value2","key3":["value2"]}'
    echo -e $file_string > ${input_file}
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    [ "$?" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_invalid_input" {
    # Missing '}' at EOF
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"value1", "key2":"value2"'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_invalid_from_boolean" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"value1", "key2":true}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_invalid_from_integer" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"value1", "key2":123}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_invalid_from_float" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"value1", "key2":123.123}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_empty_input_file_path" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    set +e
    BASH_EVALUATED_JSON "" IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
}

################################################################################
################################################################################

@test "test_nested_json_objects" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":{"nested_key":"nested_value"}}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_nested_arrays" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":["value1", ["nested_value1", "nested_value2"], "value2"]}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_bash_cmnd_evaluation_in_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"$(echo evaluated_value)"}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_bash_cmnd_evaluation_in_array_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":["$(echo value1)","$(echo value2)"]}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_boolean_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":true, "key2":false}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_integer_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":123, "key2":456}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_float_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":123.456, "key2":456.123}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_array_with_non_string_values" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":["string1", 123, true]}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_json_array_with_strings" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":["value1","value2","value3"]}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_multiple_escaped_quotes" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":"This is a string with multiple escaped quotes: \"quote1\" and \"quote2\""}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_key_with_spaces" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key with spaces":"value"}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_empty_array" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{"key1":[]}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_bash_cmnds_1" {
    test_init

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "ian":"smells"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # BASH_EVALUATED_JSON the json file
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo '    "ian":"smells"' >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "${new_contents}" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_2" {
    test_init

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "ian_1":"smells",' >> ${input_file}
    echo '    "ian_2":"smells",' >> ${input_file}
    echo '    "ian_3":"smells",' >> ${input_file}
    echo '    "ian_4":"smells"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo '    "ian_1":"smells",' >> ${expects_file}
    echo '    "ian_2":"smells",' >> ${expects_file}
    echo '    "ian_3":"smells",' >> ${expects_file}
    echo '    "ian_4":"smells"' >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_3" {
    test_init

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "simple_cmnd":"$(echo hello world)"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo '    "simple_cmnd":"hello world"' >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_4" {
    test_init

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "simple_cmnd_1":"The man says $(echo hello world)",' >> ${input_file}
    echo '    "simple_cmnd_2":"The man says $(echo hello world)",' >> ${input_file}
    echo '    "simple_cmnd_3":"The man says $(echo hello world)",' >> ${input_file}
    echo '    "simple_cmnd_4":"The man says $(echo hello world)"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo '    "simple_cmnd_1":"The man says hello world",' >> ${expects_file}
    echo '    "simple_cmnd_2":"The man says hello world",' >> ${expects_file}
    echo '    "simple_cmnd_3":"The man says hello world",' >> ${expects_file}
    echo '    "simple_cmnd_4":"The man says hello world"' >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_5" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "nested_cmnds_1":"The date is $(echo $($DATE_CMD))",' >> ${input_file}
    echo '    "nested_cmnds_2":"The date is $(echo $($DATE_CMD))",' >> ${input_file}
    echo '    "nested_cmnds_3":"The date is $(echo $($DATE_CMD))",' >> ${input_file}
    echo '    "nested_cmnds_4":"The date is $(echo $($DATE_CMD))"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo "    \"nested_cmnds_1\":\"The date is $(echo $($DATE_CMD))\"," >> ${expects_file}
    echo "    \"nested_cmnds_2\":\"The date is $(echo $($DATE_CMD))\"," >> ${expects_file}
    echo "    \"nested_cmnds_3\":\"The date is $(echo $($DATE_CMD))\"," >> ${expects_file}
    echo "    \"nested_cmnds_4\":\"The date is $(echo $($DATE_CMD))\"" >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_6" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export UNAME_CMD="uname -s"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "complex_expression":"$(echo $($DATE_CMD) $($UNAME_CMD))"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo "    \"complex_expression\":\"$(echo $($DATE_CMD) $($UNAME_CMD))\"" >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_7" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "IAN_SMELLS":"$(echo ${IAN_SMELLS})"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo "    \"IAN_SMELLS\":\"$(echo ${IAN_SMELLS})\"" >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_8" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "IAN_SMELLS":"${IAN_SMELLS}"' >> ${input_file}
    echo '}' >> ${input_file}

    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo "    \"IAN_SMELLS\":\"${IAN_SMELLS}\"" >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_9" {
    test_init
    export USER="ian"
    export MESSAGE="smells like milk"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "dynamic_message":"$(echo ${USER} ${MESSAGE})"' >> ${input_file}
    echo '}' >> ${input_file}

    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo '    "dynamic_message":"ian smells like milk"' >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_10" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export USER="ian"

    # Create the input JSON file
    echo '{' > ${input_file}
    echo '    "user_with_date":"$(echo ${USER} $($DATE_CMD))"' >> ${input_file}
    echo '}' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the JSON
    local new_contents=$(BASH_EVALUATED_JSON ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected JSON file
    echo '{' > ${expects_file}
    echo "    \"user_with_date\":\"${USER} $(date +%Y-%m-%d)\"" >> ${expects_file}
    echo '}' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated JSON with the expected JSON
    diff <(echo "$new_contents" | jq -S .) <(jq -S . ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_disallowed_escaped_characters" {
    test_init
    local disallowed_chars=('\\t' '\\n' '\\r' '\\b' '\\f' '\\\\' '\\/')
    for char in "${disallowed_chars[@]}"; do
        local json_string='{"key1":"This is a string with an escaped character: '"$char"'"}'
        echo $json_string > disallowed_escaped_character.json
        run BASH_EVALUATED_JSON disallowed_escaped_character.json IS_TEST
        [ "$status" -ne 0 ]
        rm disallowed_escaped_character.json
    done
}

################################################################################
################################################################################

@test "test_allowed_escaped_character" {
    test_init
    local json_string='{"key1":"This is a string with an escaped quote: \"value\""}'
    echo $json_string > allowed_escaped_character.json
    run BASH_EVALUATED_JSON allowed_escaped_character.json IS_TEST
    [ "$status" -eq 0 ]
    rm allowed_escaped_character.json
}

################################################################################
################################################################################

@test "test_empty_object" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='{}'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_JSON ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

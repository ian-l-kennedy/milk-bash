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

load 'test_helper.bash'

@test "test_valid_input" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    local json_string='{"key1":"value1","key2":"value2"}'
    echo $json_string > valid_input.json
    run BASH_EVALUATED_JSON valid_input.json IS_TEST
    [ "$status" -eq 0 ]
    rm valid_input.json
}

################################################################################
################################################################################

@test "test_invalid_input" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    echo '{"key1":"value1", "key2":"value2"' > invalid_input.json
    run BASH_EVALUATED_JSON invalid_input.json IS_TEST
    [ "$status" -ne 0 ]
    rm invalid_input.json
}

################################################################################
################################################################################

@test "test_empty_input_file_path" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    run BASH_EVALUATED_JSON "" IS_TEST
    [ "$status" -ne 0 ]
}

################################################################################
################################################################################

@test "test_nested_json_objects" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    echo '{"key1":{"nested_key":"nested_value"}}' > nested_input.json
    run BASH_EVALUATED_JSON nested_input.json IS_TEST
    [ "$status" -ne 0 ]
    rm nested_input.json
}

################################################################################
################################################################################

@test "test_nested_arrays" {
    test_init
    local json_string='{"key1":["value1", ["nested_value1", "nested_value2"], "value2"]}'
    echo $json_string > nested_arrays.json
    run BASH_EVALUATED_JSON nested_arrays.json IS_TEST
    [ "$status" -ne 0 ]
    rm nested_arrays.json
}

################################################################################
################################################################################

@test "test_bash_cmnd_evaluation_in_values" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    echo '{"key1":"$(echo evaluated_value)"}' > command_input.json
    run BASH_EVALUATED_JSON command_input.json IS_TEST
    [ "$status" -eq 0 ]
    rm command_input.json
}

################################################################################
################################################################################

@test "test_bash_cmnd_evaluation_in_array_values" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    echo '{"key1":["$(echo value1)","$(echo value2)"]}' > command_array_input.json
    run BASH_EVALUATED_JSON command_array_input.json IS_TEST
    [ "$status" -eq 0 ]
    rm command_array_input.json
}

################################################################################
################################################################################

@test "test_bash_cmnds_1" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "ian":"smells"' >> ${jsn}
    echo '}' >> ${jsn}
    test_print_stim ${jsn}

    # BASH_EVALUATED_JSON the json file
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "ian":"smells"' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_2" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "ian_1":"smells",' >> ${jsn}
    echo '    "ian_2":"smells",' >> ${jsn}
    echo '    "ian_3":"smells",' >> ${jsn}
    echo '    "ian_4":"smells"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "ian_1":"smells",' >> ${golden}
    echo '    "ian_2":"smells",' >> ${golden}
    echo '    "ian_3":"smells",' >> ${golden}
    echo '    "ian_4":"smells"' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_3" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "simple_cmnd":"$(echo hello world)"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "simple_cmnd":"hello world"' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_4" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "simple_cmnd_1":"The man says $(echo hello world)",' >> ${jsn}
    echo '    "simple_cmnd_2":"The man says $(echo hello world)",' >> ${jsn}
    echo '    "simple_cmnd_3":"The man says $(echo hello world)",' >> ${jsn}
    echo '    "simple_cmnd_4":"The man says $(echo hello world)"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "simple_cmnd_1":"The man says hello world",' >> ${golden}
    echo '    "simple_cmnd_2":"The man says hello world",' >> ${golden}
    echo '    "simple_cmnd_3":"The man says hello world",' >> ${golden}
    echo '    "simple_cmnd_4":"The man says hello world"' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_5" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "nested_cmnds_1":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
    echo '    "nested_cmnds_2":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
    echo '    "nested_cmnds_3":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
    echo '    "nested_cmnds_4":"The date is $(echo $($DATE_CMD))"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"nested_cmnds_1\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
    echo "    \"nested_cmnds_2\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
    echo "    \"nested_cmnds_3\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
    echo "    \"nested_cmnds_4\":\"The date is $(echo $($DATE_CMD))\"" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_6" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export UNAME_CMD="uname -s"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "complex_expression":"$(echo $($DATE_CMD) $($UNAME_CMD))"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"complex_expression\":\"$(echo $($DATE_CMD) $($UNAME_CMD))\"" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_7" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "IAN_SMELLS":"$(echo ${IAN_SMELLS})"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"IAN_SMELLS\":\"$(echo ${IAN_SMELLS})\"" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_8" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "IAN_SMELLS":"${IAN_SMELLS}"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"IAN_SMELLS\":\"${IAN_SMELLS}\"" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_9" {
    test_init
    export USER="ian"
    export MESSAGE="smells like milk"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "dynamic_message":"$(echo ${USER} ${MESSAGE})"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "dynamic_message":"ian smells like milk"' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_10" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export USER="ian"

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "user_with_date":"$(echo ${USER} $($DATE_CMD))"' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    local new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"user_with_date\":\"${USER} $(date +%Y-%m-%d)\"" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

@test "test_boolean_values" {
    test_init
    local json_string='{"key1":true, "key2":false}'
    echo $json_string > boolean_values.json
    run BASH_EVALUATED_JSON boolean_values.json IS_TEST
    [ "$status" -ne 0 ]
    rm boolean_values.json
}

@test "test_integer_values" {
    test_init
    local json_string='{"key1":123, "key2":456}'
    echo $json_string > integer_values.json
    run BASH_EVALUATED_JSON integer_values.json IS_TEST
    [ "$status" -ne 0 ]
    rm integer_values.json
}

@test "test_array_with_non_string_values" {
    test_init
    local json_string='{"key1":["string1", 123, true]}'
    echo $json_string > array_non_string_values.json
    run BASH_EVALUATED_JSON array_non_string_values.json IS_TEST
    [ "$status" -ne 0 ]
    rm array_non_string_values.json
}

@test "test_json_array_with_strings" {
    test_init
    local json_string='{"key1":["value1","value2","value3"]}'
    echo $json_string > array_with_strings.json
    run BASH_EVALUATED_JSON array_with_strings.json IS_TEST
    [ "$status" -eq 0 ]
    rm array_with_strings.json
}

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

@test "test_allowed_escaped_character" {
    test_init
    local json_string='{"key1":"This is a string with an escaped quote: \"value\""}'
    echo $json_string > allowed_escaped_character.json
    run BASH_EVALUATED_JSON allowed_escaped_character.json IS_TEST
    [ "$status" -eq 0 ]
    rm allowed_escaped_character.json
}

@test "test_empty_json_object" {
    test_init
    local json_string='{}'
    echo $json_string > empty_json_object.json
    run BASH_EVALUATED_JSON empty_json_object.json IS_TEST
    [ "$status" -eq 0 ]
    rm empty_json_object.json
}

@test "test_multiple_escaped_quotes" {
    test_init
    local json_string='{"key1":"This is a string with multiple escaped quotes: \"quote1\" and \"quote2\""}'
    echo $json_string > multiple_escaped_quotes.json
    run BASH_EVALUATED_JSON multiple_escaped_quotes.json IS_TEST
    [ "$status" -eq 0 ]
    rm multiple_escaped_quotes.json
}

@test "test_key_with_spaces" {
    test_init
    local json_string='{"key with spaces":"value"}'
    echo $json_string > key_with_spaces.json
    run BASH_EVALUATED_JSON key_with_spaces.json IS_TEST
    [ "$status" -eq 0 ]
    rm key_with_spaces.json
}

@test "test_empty_array" {
    test_init
    local json_string='{"key1":[]}'
    echo $json_string > empty_array.json
    run BASH_EVALUATED_JSON empty_array.json IS_TEST
    [ "$status" -eq 0 ]
    rm empty_array.json
}

@test "test_array_simple" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "simple_array":["$(echo element1)", "$(echo element2)", "$(echo element3)"]' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo '    "simple_array":["element1", "element2", "element3"]' >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

@test "test_array_complex" {
    test_init

    # Create the input JSON file
    echo '{' > ${jsn}
    echo '    "complex_array":["$(echo $USER $(date +%Y-%m-%d))", "$(echo $USER $(uname -s))", "$(echo $USER $(pwd))"]' >> ${jsn}
    echo '}' >> ${jsn}

    test_print_stim ${jsn}

    # Evaluate the JSON
    new_json=$(BASH_EVALUATED_JSON ${jsn})
    echo "new_json (BASH_EVALUATED_JSON):"
    echo "$new_json" | jq '.'
    [ "$?" -eq 0 ]

    # Create the golden JSON file
    echo '{' > ${golden}
    echo "    \"complex_array\":[\"$USER $(date +%Y-%m-%d)\", \"$USER $(uname -s)\", \"$USER $(pwd)\"]" >> ${golden}
    echo '}' >> ${golden}

    test_print_exp ${golden}

    test_print_obs "${new_json}"

    # Compare the evaluated JSON with the golden JSON
    diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
    [ "$?" -eq 0 ]
}

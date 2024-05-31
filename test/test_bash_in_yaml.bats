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
    REQUIRE_COMMAND yq
    input_file=input.yml
    observes_file=observes.yml
    expects_file=expects.yml
    rm -f ${input_file}
    rm -f ${observes_file}
    rm -f ${expects_file}
}

function test_exit () {
    rm -f ${input_file}
    rm -f ${observes_file}
    rm -f ${expects_file}
}

function test_print_stim () {
    # Print input test stimulus
    echo "Test input stimulus:"
    yq -P . ${1}
    echo ""
}

function test_print_exp () {
    # Print output expects
    echo "Test output expects:"
    yq -P . ${1}
    echo ""
}

function test_print_obs () {
    # Print output observes
    echo "Test output observes:"
    echo "$1" | yq -P .
    echo ""
}

@test "test_valid_input" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='key1: value1\nkey2: value2\nkey3: [value1,value2]\nkey4:\n  - value1\n  - value2\n'
    echo -e $file_string > ${input_file}
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    [ "$?" -eq 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_invalid_input" {
    # Missing ':' after key2
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='key1: value1\nkey2 value2\n'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: value1\nkey2: true\n'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: value1\nkey2: 123\n'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: value1\nkey2: 123.123\n'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    BASH_EVALUATED_YAML "" IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
}

################################################################################
################################################################################

@test "test_nested_json_objects" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='key1: value1\nkey2:\n  nested_key: value2\n'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1:\n  - value1\n  - \n    - nested_value1\n    - nested_value2\n  - value2'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: $(echo evaluated_value)'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1:\n  - $(echo value1)\n  - $(echo value2)'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: true\nkey2: false'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: 123\nkey2: 456'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: 123.456\nkey2: 456.123'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1:\n  - "string1"\n  - 123\n  - true'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_yaml_array_with_strings" {
    test_init
    cd "$BATS_TEST_DIRNAME"
    local file_string='key1:\n  - "value1"\n  - "value2"\n  - "value3"'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: "This is a string with multiple escaped quotes: \"quote1\" and \"quote2\""'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key with spaces: "value"'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
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
    local file_string='key1: []'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}



################################################################################
################################################################################

@test "test_bash_cmnds_1" {
    test_init

    # Create the input YAML file
    echo 'ian: smells' > ${input_file}
    test_print_stim ${input_file}

    # BASH_EVALUATED_YAML the yaml file
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo 'ian: smells' > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "${new_contents}" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_2" {
    test_init

    # Create the input YAML file
    echo 'ian_1: smells' > ${input_file}
    echo 'ian_2: smells' >> ${input_file}
    echo 'ian_3: smells' >> ${input_file}
    echo 'ian_4: smells' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo 'ian_1: smells' > ${expects_file}
    echo 'ian_2: smells' >> ${expects_file}
    echo 'ian_3: smells' >> ${expects_file}
    echo 'ian_4: smells' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_3" {
    test_init

    # Create the input YAML file
    echo 'simple_cmnd: $(echo hello world)' > ${input_file}

    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo 'simple_cmnd: hello world' > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}


################################################################################
################################################################################

@test "test_bash_cmnds_4" {
    test_init

    # Create the input YAML file
    echo 'simple_cmnd_1: "The man says $(echo hello world)"' > ${input_file}
    echo 'simple_cmnd_2: "The man says $(echo hello world)"' >> ${input_file}
    echo 'simple_cmnd_3: "The man says $(echo hello world)"' >> ${input_file}
    echo 'simple_cmnd_4: "The man says $(echo hello world)"' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo 'simple_cmnd_1: "The man says hello world"' > ${expects_file}
    echo 'simple_cmnd_2: "The man says hello world"' >> ${expects_file}
    echo 'simple_cmnd_3: "The man says hello world"' >> ${expects_file}
    echo 'simple_cmnd_4: "The man says hello world"' >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_5" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"

    # Create the input YAML file
    echo 'nested_cmnds_1: "The date is $(echo $($DATE_CMD))"' > ${input_file}
    echo 'nested_cmnds_2: "The date is $(echo $($DATE_CMD))"' >> ${input_file}
    echo 'nested_cmnds_3: "The date is $(echo $($DATE_CMD))"' >> ${input_file}
    echo 'nested_cmnds_4: "The date is $(echo $($DATE_CMD))"' >> ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "nested_cmnds_1: \"The date is $(echo $($DATE_CMD))\"" > ${expects_file}
    echo "nested_cmnds_2: \"The date is $(echo $($DATE_CMD))\"" >> ${expects_file}
    echo "nested_cmnds_3: \"The date is $(echo $($DATE_CMD))\"" >> ${expects_file}
    echo "nested_cmnds_4: \"The date is $(echo $($DATE_CMD))\"" >> ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_6" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export UNAME_CMD="uname -s"

    # Create the input YAML file
    echo 'complex_expression: "$(echo $($DATE_CMD) $($UNAME_CMD))"' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "complex_expression: \"$(echo $($DATE_CMD) $($UNAME_CMD))\"" > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_7" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input YAML file
    echo 'IAN_SMELLS: "$(echo ${IAN_SMELLS})"' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "IAN_SMELLS: \"$(echo ${IAN_SMELLS})\"" > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}


################################################################################
################################################################################

@test "test_bash_cmnds_8" {
    test_init
    export IAN_SMELLS="ian smells like milk"

    # Create the input YAML file
    echo 'IAN_SMELLS: "${IAN_SMELLS}"' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "IAN_SMELLS: \"${IAN_SMELLS}\"" > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_9" {
    test_init
    export USER="ian"
    export MESSAGE="smells like milk"

    # Create the input YAML file
    echo 'dynamic_message: "$(echo ${USER} ${MESSAGE})"' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo 'dynamic_message: "ian smells like milk"' > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_bash_cmnds_10" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export USER="ian"

    # Create the input YAML file
    echo 'user_with_date: "$(echo ${USER} $($DATE_CMD))"' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "user_with_date: \"${USER} $(date +%Y-%m-%d)\"" > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

################################################################################
################################################################################

@test "test_empty_file" {
    test_init
    touch ${input_file}
    unset ENABLE_BASH_LOGGER_DEBUG
    result=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]
    [ "$result" = "" ]
    test_exit
}

@test "test_file_with_comments" {
    test_init
    echo "# This is a comment" > ${input_file}
    echo "# Another comment" >> ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

@test "test_escaped_characters_in_values" {
    test_init
    local file_string='key1: "This is a test with a newline \\n and a tab \\t and a backslash \\\\"'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}

################################################################################
################################################################################

@test "test_multiline_strings" {
    test_init
    export DATE_CMD="date +%Y-%m-%d"
    export USER="ian"

    # Create the input YAML file
    echo -e 'key1: |-\n  This is a\n  multiline\n  string' > ${input_file}
    test_print_stim ${input_file}

    # Evaluate the YAML
    local new_contents=$(BASH_EVALUATED_YAML ${input_file})
    [ "$?" -eq 0 ]

    # Create the expected YAML file
    echo "key1: This is a multiline string" > ${expects_file}

    test_print_exp ${expects_file}

    test_print_obs "${new_contents}"

    # Compare the evaluated YAML with the expected YAML
    diff <(echo "$new_contents" | yq -P) <(yq -P ${expects_file})
    [ "$?" -eq 0 ]
}

@test "test_special_characters_in_keys" {
    test_init
    local file_string='key-with-dashes: value\nkey_with_underscores: value\nkey with spaces: value'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

@test "test_array_with_empty_strings" {
    test_init
    local file_string='key1:\n  - ""\n  - "value1"\n  - ""\n  - "value2"'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -eq 0 ]
    test_exit
}

@test "test_nested_arrays_with_mixed_types" {
    test_init
    local file_string='key1:\n  - "string1"\n  - 123\n  - "string2"\n  - true'
    echo -e "$file_string" > ${input_file}
    set +e
    BASH_EVALUATED_YAML ${input_file} IS_TEST
    exit_code=$?
    set -e
    [ "$exit_code" -ne 0 ]
    test_exit
}


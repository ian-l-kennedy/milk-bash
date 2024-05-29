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

@test "test_put_string_methods" {
    set -e
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    strng="Hello World!"
    DEBUG ${strng}
    INFO ${strng}
    NOTICE ${strng}
    WARNING ${strng}
    ERROR ${strng}
    CRITICAL ${strng}
    ALERT ${strng}
    EMERGENCY ${strng}
}

@test "test_require_command_not_on_path" {
    echo "Testing the positive case, command found ..."
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    REQUIRE_COMMAND bash
    [ "$?" -eq 0 ]
    echo "Testing the negative case, command not found ..."
    set +e
    (REQUIRE_COMMAND milk_is_sometimes_smelly)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test "test_require_command_with_empty_input" {
    echo "Testing the negative case, command string empty ..."
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    set +e
    (REQUIRE_COMMAND "")
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test "test_require_command_with_non_executable" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    touch non_executable_command
    chmod -x non_executable_command
    export PATH="$PWD:$PATH"
    set +e
    (REQUIRE_COMMAND non_executable_command)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
    rm non_executable_command
}

@test "test_require_command_with_valid_executable" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    touch valid_executable_command
    chmod +x valid_executable_command
    export PATH="$PWD:$PATH"
    (REQUIRE_COMMAND valid_executable_command)
    [ "$?" -eq 0 ]
    rm valid_executable_command
}

@test "test_require_command_with_different_locations" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    mkdir -p bin1 bin2
    touch bin1/test_command
    touch bin2/test_command
    chmod +x bin1/test_command bin2/test_command
    export PATH="$PWD/bin1:$PWD/bin2:$PATH"
    (REQUIRE_COMMAND test_command)
    [ "$?" -eq 0 ]
    rm -r bin1 bin2
}






































# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_1 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "ian":"smells"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "ian":"smells"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_2 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "ian_1":"smells",' >> ${jsn}
#     echo '    "ian_2":"smells",' >> ${jsn}
#     echo '    "ian_3":"smells",' >> ${jsn}
#     echo '    "ian_4":"smells"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "ian_1":"smells",' >> ${golden}
#     echo '    "ian_2":"smells",' >> ${golden}
#     echo '    "ian_3":"smells",' >> ${golden}
#     echo '    "ian_4":"smells"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_3 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "simple_command":"$(echo hello world)"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "simple_command":"hello world"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_4 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "simple_command_1":"The man says $(echo hello world)",' >> ${jsn}
#     echo '    "simple_command_2":"The man says $(echo hello world)",' >> ${jsn}
#     echo '    "simple_command_3":"The man says $(echo hello world)",' >> ${jsn}
#     echo '    "simple_command_4":"The man says $(echo hello world)"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "simple_command_1":"The man says hello world",' >> ${golden}
#     echo '    "simple_command_2":"The man says hello world",' >> ${golden}
#     echo '    "simple_command_3":"The man says hello world",' >> ${golden}
#     echo '    "simple_command_4":"The man says hello world"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_5 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export DATE_CMD="date +%Y-%m-%d"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "nested_commands_1":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
#     echo '    "nested_commands_2":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
#     echo '    "nested_commands_3":"The date is $(echo $($DATE_CMD))",' >> ${jsn}
#     echo '    "nested_commands_4":"The date is $(echo $($DATE_CMD))"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo "    \"nested_commands_1\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
#     echo "    \"nested_commands_2\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
#     echo "    \"nested_commands_3\":\"The date is $(echo $($DATE_CMD))\"," >> ${golden}
#     echo "    \"nested_commands_4\":\"The date is $(echo $($DATE_CMD))\"" >> ${golden}
#     echo '}' >> ${golden}

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_6 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export DATE_CMD="date +%Y-%m-%d"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "complex_expression":"$(echo $($DATE_CMD) $($UNAME_CMD))"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo "    \"complex_expression\":\"$(echo $($DATE_CMD) $($UNAME_CMD))\"" >> ${golden}
#     echo '}' >> ${golden}

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_7 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export IAN_SMELLS="ian smells like milk"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "IAN_SMELLS":"$(echo ${IAN_SMELLS})"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo "    \"IAN_SMELLS\":\"$(echo ${IAN_SMELLS})\"" >> ${golden}
#     echo '}' >> ${golden}

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_8 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export IAN_SMELLS="ian smells like milk"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "IAN_SMELLS":"${IAN_SMELLS}"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo "    \"IAN_SMELLS\":\"${IAN_SMELLS}\"" >> ${golden}
#     echo '}' >> ${golden}

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_9 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "json_in_json":"$(echo {\"inner_key\":\"inner_value\"})"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "json_in_json":"{\"inner_key\":\"inner_value\"}"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_10 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export DATE_CMD="date +%Y-%m-%d"
#     export DATE_ISO_CMD="date +%Y-%m-%dT%H:%M:%SZ"
#     export TIMESTAMP_CMD="date +%s"
#     export HOST_CMD="grep -m 1 nameserver /etc/resolv.conf | awk '{print \$2}'"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "docker_build_params_append":"$(echo --quiet) $(echo --platform=linux/amd64) # $(echo --build-arg) $(echo BUILD_DATE=$($DATE_CMD)) $(echo --label) $(echo org.# label-schema.build-date=$($DATE_ISO_CMD)) $(echo --label) $(echo com.# example.version=$(echo 1.0.$($TIMESTAMP_CMD))) $(echo --add-host) $(echo host.docker.# internal:$($HOST_CMD)) $(echo # --network) $(echo host) $(echo --env) $(echo ENV_VAR1=value1) $(echo --env) $(echo # ENV_VAR2=value2) $(echo --env-file) $(echo <(echo ENV_VAR3=value3 ENV_VAR4=value4))"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "docker_build_params_append":"--quiet --platform=linux/amd64 # --build-arg BUILD_DATE=$(date +%Y-%m-%d) --label org.# label-schema.build-date=$(date +%Y-%m-%dT%H:%M:%SZ) --label com.# example.version=1.0.$(date +%s) --add-host host.docker.# internal:$(grep -m 1 nameserver /etc/resolv.conf | awk '\''{print \$2}'\'') # --network host --env ENV_VAR1=value1 --env # ENV_VAR2=value2 --env-file <(echo ENV_VAR3=value3 ENV_VAR4=value4)"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# ################################################################################

# @test test_bash_evaluated_json_11 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "ian":[' >> ${jsn}
#     echo '        "smells",' >> ${jsn}
#     echo '        "like",' >> ${jsn}
#     echo '        "milk"' >> ${jsn}
#     echo '    ]' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "ian":[' >> ${golden}
#     echo '        "smells",' >> ${golden}
#     echo '        "like",' >> ${golden}
#     echo '        "milk"' >> ${golden}
#     echo '    ]' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_12 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export NESTED_KEY="nested_value"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "complex_structure": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT2)"' >> ${jsn}
#     echo '        ],' >> ${jsn}
#     echo '        "nested": {' >> ${jsn}
#     echo '            "key": "$(echo $NESTED_KEY)"' >> ${jsn}
#     echo '        }' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "complex_structure": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "element1",' >> ${golden}
#     echo '            "element2"' >> ${golden}
#     echo '        ],' >> ${golden}
#     echo '        "nested": {' >> ${golden}
#     echo '            "key": "nested_value"' >> ${golden}
#     echo '        }' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_13 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export NESTED_KEY="nested_value"
#     export NESTED_ARRAY_ELEMENT="nested_array_element"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "complex_structure": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT2)"' >> ${jsn}
#     echo '        ],' >> ${jsn}
#     echo '        "nested": {' >> ${jsn}
#     echo '            "key": "$(echo $NESTED_KEY)",' >> ${jsn}
#     echo '            "nested_array": [' >> ${jsn}
#     echo '                "$(echo $NESTED_ARRAY_ELEMENT)"' >> ${jsn}
#     echo '            ]' >> ${jsn}
#     echo '        }' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "complex_structure": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "element1",' >> ${golden}
#     echo '            "element2"' >> ${golden}
#     echo '        ],' >> ${golden}
#     echo '        "nested": {' >> ${golden}
#     echo '            "key": "nested_value",' >> ${golden}
#     echo '            "nested_array": [' >> ${golden}
#     echo '                "nested_array_element"' >> ${golden}
#     echo '            ]' >> ${golden}
#     echo '        }' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_14 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export NESTED_KEY="nested_value"
#     export NESTED_ARRAY_ELEMENT="nested_array_element"
#     export ANOTHER_NESTED_KEY="another_nested_value"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "complex_structure": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT2)"' >> ${jsn}
#     echo '        ],' >> ${jsn}
#     echo '        "nested": {' >> ${jsn}
#     echo '            "key": "$(echo $NESTED_KEY)",' >> ${jsn}
#     echo '            "nested_array": [' >> ${jsn}
#     echo '                "$(echo $NESTED_ARRAY_ELEMENT)"' >> ${jsn}
#     echo '            ],' >> ${jsn}
#     echo '            "another_nested": {' >> ${jsn}
#     echo '                "key": "$(echo $ANOTHER_NESTED_KEY)"' >> ${jsn}
#     echo '            }' >> ${jsn}
#     echo '        }' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "complex_structure": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "element1",' >> ${golden}
#     echo '            "element2"' >> ${golden}
#     echo '        ],' >> ${golden}
#     echo '        "nested": {' >> ${golden}
#     echo '            "key": "nested_value",' >> ${golden}
#     echo '            "nested_array": [' >> ${golden}
#     echo '                "nested_array_element"' >> ${golden}
#     echo '            ],' >> ${golden}
#     echo '            "another_nested": {' >> ${golden}
#     echo '                "key": "another_nested_value"' >> ${golden}
#     echo '            }' >> ${golden}
#     echo '        }' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# @test test_bash_evaluated_json_15 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export CMD="echo Hello World"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "command_result":"$(echo $($CMD))"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "command_result":"Hello World"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# @test test_bash_evaluated_json_16 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export CMD1="echo Hello"
#     export CMD2="echo World"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "command_result":"$($CMD1) $($CMD2)"' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "command_result":"Hello World"' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# @test test_bash_evaluated_json_17 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export ELEMENT3="element3"
#     export ELEMENT4="element4"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "array": [' >> ${jsn}
#     echo '        "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '        "$(echo $ELEMENT2)",' >> ${jsn}
#     echo '        "$(echo $ELEMENT3)",' >> ${jsn}
#     echo '        "$(echo $ELEMENT4)"' >> ${jsn}
#     echo '    ]' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "array": [' >> ${golden}
#     echo '        "element1",' >> ${golden}
#     echo '        "element2",' >> ${golden}
#     echo '        "element3",' >> ${golden}
#     echo '        "element4"' >> ${golden}
#     echo '    ]' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

# @test test_bash_evaluated_json_18 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT="element"
#     export NESTED_ELEMENT="nested_element"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "array": [' >> ${jsn}
#     echo '        "$(echo $ELEMENT)"' >> ${jsn}
#     echo '    ],' >> ${jsn}
#     echo '    "nested": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $NESTED_ELEMENT)"' >> ${jsn}
#     echo '        ]' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "array": [' >> ${golden}
#     echo '        "element"' >> ${golden}
#     echo '    ],' >> ${golden}
#     echo '    "nested": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "nested_element"' >> ${golden}
#     echo '        ]' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# @test test_bash_evaluated_json_19 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export NESTED_ELEMENT1="nested_element1"
#     export NESTED_ELEMENT2="nested_element2"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "array": [' >> ${jsn}
#     echo '        "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '        "$(echo $ELEMENT2)"' >> ${jsn}
#     echo '    ],' >> ${jsn}
#     echo '    "nested": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $NESTED_ELEMENT1)",' >> ${jsn}
#     echo '            "$(echo $NESTED_ELEMENT2)"' >> ${jsn}
#     echo '        ]' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "array": [' >> ${golden}
#     echo '        "element1",' >> ${golden}
#     echo '        "element2"' >> ${golden}
#     echo '    ],' >> ${golden}
#     echo '    "nested": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "nested_element1",' >> ${golden}
#     echo '            "nested_element2"' >> ${golden}
#     echo '        ]' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################

# @test test_bash_evaluated_json_20 {
#     set -e
#     cd "$BATS_TEST_DIRNAME"
#     source ../src/milk.bash
#     REQUIRE_COMMAND bash
#     REQUIRE_COMMAND jq
#     export ELEMENT1="element1"
#     export ELEMENT2="element2"
#     export ELEMENT3="element3"
#     export ELEMENT4="element4"
#     export NESTED_ELEMENT1="nested_element1"
#     export NESTED_ELEMENT2="nested_element2"
#     export NESTED_ELEMENT3="nested_element3"
#     export NESTED_ELEMENT4="nested_element4"

#     # Create the input JSON file
#     jsn=testing.json
#     rm -f ${jsn}
#     echo '{' > ${jsn}
#     echo '    "complex_structure": {' >> ${jsn}
#     echo '        "array": [' >> ${jsn}
#     echo '            "$(echo $ELEMENT1)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT2)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT3)",' >> ${jsn}
#     echo '            "$(echo $ELEMENT4)"' >> ${jsn}
#     echo '        ],' >> ${jsn}
#     echo '        "nested": {' >> ${jsn}
#     echo '            "array": [' >> ${jsn}
#     echo '                "$(echo $NESTED_ELEMENT1)",' >> ${jsn}
#     echo '                "$(echo $NESTED_ELEMENT2)",' >> ${jsn}
#     echo '                "$(echo $NESTED_ELEMENT3)",' >> ${jsn}
#     echo '                "$(echo $NESTED_ELEMENT4)"' >> ${jsn}
#     echo '            ]' >> ${jsn}
#     echo '        }' >> ${jsn}
#     echo '    }' >> ${jsn}
#     echo '}' >> ${jsn}

#     # Print input test stimulus
#     echo "Test input stimulus:"
#     jq -S . ${jsn}
#     echo ""

#     # Evaluate the JSON
#     new_json=$(BASH_EVALUATED_JSON ${jsn})
#     echo "$new_json" | jq '.'
#     [ "$?" -eq 0 ]

#     # Create the golden JSON file
#     golden=golden.json
#     rm -f ${golden}
#     echo '{' > ${golden}
#     echo '    "complex_structure": {' >> ${golden}
#     echo '        "array": [' >> ${golden}
#     echo '            "element1",' >> ${golden}
#     echo '            "element2",' >> ${golden}
#     echo '            "element3",' >> ${golden}
#     echo '            "element4"' >> ${golden}
#     echo '        ],' >> ${golden}
#     echo '        "nested": {' >> ${golden}
#     echo '            "array": [' >> ${golden}
#     echo '                "nested_element1",' >> ${golden}
#     echo '                "nested_element2",' >> ${golden}
#     echo '                "nested_element3",' >> ${golden}
#     echo '                "nested_element4"' >> ${golden}
#     echo '            ]' >> ${golden}
#     echo '        }' >> ${golden}
#     echo '    }' >> ${golden}
#     echo '}' >> ${golden}

#     # Print output expects
#     echo "Test output expects:"
#     jq -S . ${golden}
#     echo ""

#     # Print output observes
#     echo "Test output observes:"
#     echo "$new_json" | jq -S .
#     echo ""

#     # Compare the evaluated JSON with the golden JSON
#     diff <(echo "$new_json" | jq -S .) <(jq -S . ${golden})
#     [ "$?" -eq 0 ]
# }

# ################################################################################
# ################################################################################

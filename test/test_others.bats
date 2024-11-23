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
    DEBUG "${strng}"
    INFO "${strng}"
    NOTICE "${strng}"
    WARNING "${strng}"
    ERROR "${strng}"
    CRITICAL "${strng}"
    ALERT "${strng}"
    EMERGENCY "${strng}"
    export ENABLE_BASH_LOGGER_DEBUG=1
    DEBUG "${strng}"
}

@test "test_require_as_user_non_root" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    REQUIRE_AS_USER
    [ "$?" -eq 0 ]
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

@test "test_require_variable_set" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    VAR="value"
    REQUIRE_VARIABLE VAR
    [ "$?" -eq 0 ]
}

@test "test_require_variable_not_set" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    set +e
    (REQUIRE_VARIABLE UNSET_VAR)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test "test_require_in_git_inside_repo" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    git init test_repo > /dev/null 2>&1
    cd test_repo
    REQUIRE_IN_GIT
    [ "$?" -eq 0 ]
    cd ..
    rm -rf test_repo
}

@test "test_require_in_git_outside_repo" {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    cd $HOME
    set +e
    (REQUIRE_IN_GIT)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test "test_repo_variables" {
    set -e
    source $(git rev-parse --show-toplevel)/src/milk.bash
    cd "$BATS_TEST_DIRNAME"
    # Check that REPO is defined and not empty
    [ -n "${REPO}" ]
    # Check that REPO_N is defined and not empty
    [ -n "${REPO_N}" ]
}

@test "test_version_json" {
    set -e
    source $(git rev-parse --show-toplevel)/src/milk.bash
    cd "$BATS_TEST_DIRNAME"
    versions_json_file=${REPO}/version.json
    rm -f ${versions_json_file}

    # Define expected version components
    expects_file_major=3
    expects_file_minor=2
    expects_file_patch=1

    # Create the version JSON file
    local file_string='{"major":"'${expects_file_major}'", "minor":"'${expects_file_minor}'", "patch":"'${expects_file_patch}'"}'
    echo -e "$file_string" > ${versions_json_file}

    # Get the version number from the script
    version_number="$(GET_VERSION_NUMBER_JSON)"

    # Check if the version_number matches the pattern \d+.\d+.\d+
    echo "$version_number" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

    # Extract major, minor, and patch using tr
    actual_major=$(echo "$version_number" | cut -d. -f1 | tr -d '[:space:]')
    actual_minor=$(echo "$version_number" | cut -d. -f2 | tr -d '[:space:]')
    actual_patch=$(echo "$version_number" | cut -d. -f3 | tr -d '[:space:]')

    # Define expected version components
    expects_epoch_major=0
    expects_epoch_minor=0
    expects_epoch_patch=${actual_patch}

    current_branch=$(git rev-parse --abbrev-ref HEAD)

    if [ "${current_branch}" == "main" ]; then
        [ "$actual_major" -eq "$expects_file_major" ]
        [ "$actual_minor" -eq "$expects_file_minor" ]
        [ "$actual_patch" -eq "$expects_file_patch" ]
    else
        [ "$actual_major" -eq "$expects_epoch_major" ]
        [ "$actual_minor" -eq "$expects_epoch_minor" ]
        [ "$actual_patch" -eq "$expects_epoch_patch" ]
    fi

    version_number="$(GET_VERSION_NUMBER_JSON main)"

    echo "$version_number" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

    actual_major=$(echo "$version_number" | cut -d. -f1 | tr -d '[:space:]')
    actual_minor=$(echo "$version_number" | cut -d. -f2 | tr -d '[:space:]')
    actual_patch=$(echo "$version_number" | cut -d. -f3 | tr -d '[:space:]')

    [ "$actual_major" -eq "$expects_file_major" ]
    [ "$actual_minor" -eq "$expects_file_minor" ]
    [ "$actual_patch" -eq "$expects_file_patch" ]

    version_number="$(GET_VERSION_NUMBER_JSON not_main)"

    echo "$version_number" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

    actual_major=$(echo "$version_number" | cut -d. -f1 | tr -d '[:space:]')
    actual_minor=$(echo "$version_number" | cut -d. -f2 | tr -d '[:space:]')
    actual_patch=$(echo "$version_number" | cut -d. -f3 | tr -d '[:space:]')

    expects_epoch_patch=${actual_patch}

    [ "$actual_major" -eq "$expects_epoch_major" ]
    [ "$actual_minor" -eq "$expects_epoch_minor" ]
    [ "$actual_patch" -eq "$expects_epoch_patch" ]
}

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

@test test_require_command_not_on_path {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    REQUIRE_COMMAND bash
    [ "$?" -eq 0 ]
    set +e
    (REQUIRE_COMMAND milk_is_sometimes_smelly)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test test_require_command_with_empty_input {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    set +e
    (REQUIRE_COMMAND "")
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test test_require_command_with_no_input {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    set +e
    (REQUIRE_COMMAND)
    local exit_code="$?"
    set -e
    [ "$exit_code" -ne 0 ]
}

@test test_require_command_with_non_executable {
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

@test test_require_command_with_valid_executable {
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    touch valid_executable_command
    chmod +x valid_executable_command
    export PATH="$PWD:$PATH"
    (REQUIRE_COMMAND valid_executable_command)
    [ "$?" -eq 0 ]
    rm valid_executable_command
}

@test test_require_command_with_different_locations {
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

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

function test_init () {
    set -e
    cd "$BATS_TEST_DIRNAME"
    source ../src/milk.bash
    REQUIRE_COMMAND bash
    REQUIRE_COMMAND jq
    jsn=testing.json
    rm -f ${jsn}
    golden=golden.json
    rm -f ${golden}
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
#!/bin/bash
set -e && cd "${0%/*}"

# rebuilds the test/data/generated2.dart file

# creating temp dir and planning to remove it
temp_build_dir=$(mktemp -d -t c99build-XXXXXXX)
trap 'echo "Removing temp dir $temp_build_dir" && rm -rf $temp_build_dir' EXIT

# compiling and running
g++ "../../../c/randomref/main.cpp" --std=c++2a -o "$temp_build_dir/compiled.exe"

# running
json="$($temp_build_dir/compiled.exe)"

# replacing double quotes to single quotes
# shellcheck disable=SC2001
json_but_single_quotes=$(sed 's/"/'\''/g' <<< "$json")

# transforming JSON into a dart file
outfile="$(realpath data/generated2.dart)"
{
  echo "// reference data for github.com/rtmigo/xrandom"
  echo "// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>"
  echo "// SPDX-License-Identifier: CC-BY-4.0"
  echo ""
  echo "// $(date)"
  echo ""
  echo "final referenceData = "
  echo "$json_but_single_quotes"
  echo ";"
} > "$outfile"

echo "Done."
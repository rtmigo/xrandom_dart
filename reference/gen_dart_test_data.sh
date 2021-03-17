#!/bin/bash
set -e && cd "${0%/*}"

# rebuilds the test/data/generated.dart file with values generated
# by newly compiled C99 program

# creating temp dir and planning to remove it
temp_build_dir=$(mktemp -d -t c99build-XXXXXXX)
trap 'echo "Removing temp dir $temp_build_dir" && rm -rf $temp_build_dir' EXIT

# compiling and running
c99 reference_prng.c -o "$temp_build_dir/exe"
outfile="$(realpath ../test/data/generated.dart)"
cd "$temp_build_dir"
"$temp_build_dir/exe"

# see files created until they're removed
# ls -s ./*.json

# combining multiple JSONs to a single Dart file
{
  echo "// reference data for github.com/rtmigo/xrandom"
  echo "// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>"
  echo "// SPDX-License-Identifier: CC-BY-4.0"
  echo ""
  echo "// $(date)"
  echo ""
  echo "final referenceData = ["
  cat ./*.json
  echo "];"
} > "$outfile"

echo "Done."
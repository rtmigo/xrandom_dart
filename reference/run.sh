#!/bin/bash
set -e && cd ${0%/*}

mkdir -p build
rm build/reference.compiled || echo "File not found"
gcc -v reference.c -o build/reference.compiled
build/reference.compiled

#//> output.txt
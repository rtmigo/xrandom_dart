#!/bin/bash
set -e && cd ${0%/*}

mkdir -p build
rm build/reference.compiled || true
gcc -v reference.c -o build/reference.compiled
build/reference.compiled

#//> output.txt
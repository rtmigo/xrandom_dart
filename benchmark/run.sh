#!/bin/bash
set -e && cd ${0%/*}

mkdir -p build
rm -rf build/benchmark.com || true
dart compile exe benchmark.dart -o build/benchmark.com
build/benchmark.com

#dart compile exe
#dart2native benchmark.dart -o build/benchmark.com

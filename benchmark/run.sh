#!/bin/bash
set -e #&& cd ${0%/*}

mkdir -p build
rm -rf build/benchmark.com || true
#dart compile exe bin/cli.dart -o build/benchmark
dart compile exe bin/cli.dart -o build/benchmark.exe
build/benchmark.exe
#build/benchmark

#dart compile exe
#dart2native benchmark.dart -o build/benchmark.com

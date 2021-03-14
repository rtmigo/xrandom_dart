#!/bin/bash
set -e && cd "${0%/*}"

mkdir -p build
rm -rf build/benchmark.com || true
dart compile exe bin/benchmark.dart -o build/benchmark.exe
build/benchmark.exe

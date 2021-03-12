#!/bin/bash
set -e && cd ${0%/*}

mkdir -p ../test
./run.sh > ../test/reference.dart

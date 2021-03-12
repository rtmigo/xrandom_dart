#!/bin/bash

#//temp_venv_dir=$(mktemp -d -t nodecrap-XXXXXXX)

set -e
#npm install tap

mkdir -p build_js
dart2js ../xorshift_dart/lib/expose.dart -o build_js/xorshift.js

node test.js


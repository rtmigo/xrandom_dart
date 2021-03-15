#!/bin/bash
set -e && cd ${0%/*}

mkdir -p build
rm build/reference.compiled || true
#gcc -v reference.c -o build/reference.compiled
c99 reference.c -o build/reference.compiled
rm generated/*.txt || true
build/reference.compiled

outfile="../test/data/generated.dart"

echo "// reference data for github.com/rtmigo/xrandom" > $outfile
echo "// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>" >> $outfile
echo "// SPDX-License-Identifier: CC-BY-4.0" >> $outfile
echo "" >> $outfile
echo "// $(date)" >> $outfile
echo "" >> $outfile
echo "final referenceData = [" >> $outfile

cat generated/*.txt >> $outfile

echo "];" >> $outfile


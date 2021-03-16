// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('node')

import "package:test/test.dart";
import 'package:xrandom/src/00_errors.dart';
import 'package:xrandom/src/xorshift64.dart';
import 'package:xrandom/src/xorshift128plus.dart';
import 'package:xrandom/src/xoshiro256pp.dart';

void main() {
  test('64', () {
    expect(()=>Xorshift64.expected(), throwsA(isA<Unsupported64Error>()));
    expect(()=>Xorshift128p.expected(), throwsA(isA<Unsupported64Error>()));
    expect(()=>Xoshiro256pp.expected(), throwsA(isA<Unsupported64Error>()));
  });
}
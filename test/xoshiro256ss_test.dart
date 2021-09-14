// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import 'package:test/test.dart';
import 'package:xrandom/src/60_xoshiro256.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Xoshiro256ss(), ()=>Xoshiro256ss.seeded());
  checkReferenceFiles(() => Xoshiro256ss(1, 2, 3, 4), 'a');
  checkReferenceFiles(() => Xoshiro256ss(5, 23, 42, 777), 'b');
  checkReferenceFiles(
      () => Xoshiro256ss(
          int.parse('0x621b97ff9b08ce44'),
          int.parse('0x92974ae633d5ee97'),
          int.parse('0x9c7e491e8f081368'),
          int.parse('0xf7d3b43bed078fa3')),
      'c');

  test('expected values', () {
    expect(expectedList(Xoshiro256ss.seeded()), [
      int.parse('5482353603764570462'),
      4000,
      0.3750582063624207,
      false,
      false,
      false
    ]);
  });
}

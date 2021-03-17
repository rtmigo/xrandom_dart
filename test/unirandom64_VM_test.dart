// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')

import 'package:test/test.dart';
import 'package:xrandom/src/20_random_base.dart';
import 'package:xrandom/src/60_xorshift128.dart';

import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/60_xorshift64.dart';

void main() {

  test('doornik', () {
    // test that the uint32->double conversion by J.Doornik will
    // not cause troubles even if we apply it to higher four bytes
    // of uint64 (that can be zero);
    expect(doornikNextFloat(0),0.5);
  });

  test('nextBool on 64-bit generator: must return all bits', () {
    final randomA = Xorshift64.expected();
    final randomB = Xorshift64.expected();

    for (var experiment = 0; experiment < 100; ++experiment) {
      var intA = randomA.nextInt64();
      for (var bit = 63; bit >= 0; --bit) {
        expect(randomB.nextBool(), (intA & (1 << bit)) != 0,
            reason: 'Experiment $experiment, bit $bit');
      }
    }
  });

  test('nextBool on 32-bit generator: must return all bits', () {
    final randomA = Xorshift128.expected();
    final randomB = Xorshift128.expected();

    for (var experiment = 0; experiment < 100; ++experiment) {
      var intA = randomA.nextInt32();
      for (var bit = 31; bit >= 0; --bit) {
        expect(randomB.nextBool(), (intA & (1 << bit)) != 0,
            reason: 'Experiment $experiment, bit $bit');
      }
    }
  });
}

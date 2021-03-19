// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import "package:test/test.dart";
import 'package:xrandom/src/60_xoshiro256pp.dart';

import 'helper.dart';

void main() {

  // print('');
  // return;

  testCommonRandom(() => Xoshiro256pp(), ()=>Xoshiro256pp.seeded());
  checkReferenceFiles(() => Xoshiro256pp(1, 2, 3, 4), 'a');
  checkReferenceFiles(() => Xoshiro256pp(5, 23, 42, 777), 'b');
  checkReferenceFiles(
      () => Xoshiro256pp(
          int.parse('0x621b97ff9b08ce44'),
          int.parse('0x92974ae633d5ee97'),
          int.parse('0x9c7e491e8f081368'),
          int.parse('0xf7d3b43bed078fa3')),
      'c');

  test('expected values', () {
    expect(expectedList(Xoshiro256pp.seeded()), [
      int.parse('9214259484446541290'),
      3031,
      0.9835800298090491,
      false,
      false,
      false
    ]);
  });
}

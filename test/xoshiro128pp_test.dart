// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/src/60_xoshiro128pp.dart';

import 'common.dart';

void main() {
  testCommonRandom(() => Xoshiro128pp(), ()=>Xoshiro128pp.seeded());
  checkReferenceFiles(() => Xoshiro128pp(1, 2, 3, 4), 'a');
  checkReferenceFiles(() => Xoshiro128pp(5, 23, 42, 777), 'b');
  checkReferenceFiles(
      () => Xoshiro128pp(1081037251, 1975530394, 2959134556, 1579461830), 'c');

  test('expected values', () {
    expect(expectedList(Xoshiro128pp.seeded()),
        [1686059242, 97217, 0.26393020434967074, false, true, false]);
  });
}

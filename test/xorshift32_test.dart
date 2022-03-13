// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/src/60_xorshift32.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Xorshift32(), ()=>Xorshift32.seeded());

  checkReferenceFiles(() => Xorshift32(1), 'a');
  checkReferenceFiles(() => Xorshift32(42), 'b');
  checkReferenceFiles(() => Xorshift32(314159265), 'c');

  checkDoornikRandbl32(() => Xorshift32(42), 'b');

  test('expected values', () {
    expect(expectedList(Xorshift32.seeded()),
        [1225539925, 51686, 0.40665327328483225, false, true, false]);
  });

  test('Create without args', () async {
    final random1 = Xorshift32();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift32();

    expect([random1.nextRaw32(), random1.nextRaw32()],
        isNot([random2.nextRaw32(), random2.nextRaw32()]));
  });
}

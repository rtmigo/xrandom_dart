// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/src/60_xorshift128.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Xorshift128(), ()=>Xorshift128.seeded());

  checkReferenceFiles(() => Xorshift128(1, 2, 3, 4), 'a');
  checkReferenceFiles(() => Xorshift128(5, 23, 42, 777), 'b');
  checkReferenceFiles(
      () => Xorshift128(1081037251, 1975530394, 2959134556, 1579461830), 'c');

  test('expected values', () {
    expect(expectedList(Xorshift128.seeded()),
        [620283008, 25651, 0.8583931512916125, false, false, false]);
  });

  test('create without args', () async {
    final random1 = Xorshift128();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift128();

    expect([random1.nextRaw32(), random1.nextRaw32()],
        isNot([random2.nextRaw32(), random2.nextRaw32()]));
  });
}

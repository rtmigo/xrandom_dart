// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import "package:test/test.dart";
import 'package:xrandom/src/60_xorshift128plus.dart';

import 'helper.dart';
import 'madsen.dart';

void main() {
  testCommonRandom(() => Xorshift128p(), () => Xorshift128p.seeded());

  checkReferenceFiles(() => Xorshift128p(1, 2), 'a');
  checkReferenceFiles(() => Xorshift128p(42, 777), 'b');
  checkReferenceFiles(() => Xorshift128p(8378522730901710845, 1653112583875186020), 'c');

  test('expected values', () {
    expect(expectedList(Xorshift128p.seeded()),
        [int.parse('8256696158060995935'), 27312, 0.04017928972328655, false, true, false]);
  });

  test('madsen double', () {
    final madsen = madsenSample["double"]!["1-2"]!;
    final random = Xorshift128p(1, 2);

    for (String expectedStr in madsen) {
      expect(random.nextDoubleBitcast(), double.parse(expectedStr));
    }
  });

  test('create without args', () async {
    final random1 = Xorshift128p();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift128p();

    expect([random1.nextRaw64(), random1.nextRaw64()],
        isNot([random2.nextRaw64(), random2.nextRaw64()]));
  });
}

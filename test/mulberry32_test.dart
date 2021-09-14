// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import 'package:test/test.dart';
import 'package:xrandom/src/60_mulberry32.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Mulberry32(), () => Mulberry32.seeded());

  checkReferenceFiles(() => Mulberry32(1), 'a');
  checkReferenceFiles(() => Mulberry32(0), 'b');
  checkReferenceFiles(() => Mulberry32(777), 'c');
  checkReferenceFiles(() => Mulberry32(1081037251), 'd');

  test('Reference values from JS generator', () {
    final exp = [
      1118692146,
      3456687457,
      2323025554,
      2964572940,
      4890715,
      3511320825,
      48751514,
      452846334,
      1703291702,
      2881671998
    ];

    final random = Mulberry32(99);
    expect(List.generate(10, (_) => random.nextRaw32()), exp);
  });
}

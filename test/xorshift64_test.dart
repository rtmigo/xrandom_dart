// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import 'package:test/test.dart';
import 'package:xrandom/src/60_xorshift64.dart';
import 'package:xrandom/xrandom.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Xorshift64(), ()=>Xorshift64.seeded());

  checkReferenceFiles(() => Xorshift64(1), 'a');
  checkReferenceFiles(() => Xorshift64(42), 'b');
  checkReferenceFiles(() => Xorshift64(3141592653589793238), 'c');

  // test('expected values', () {
  //   expect(expectedList(Xorshift64.expected()), [
  //     int.parse('-6926213550972868430'),
  //     40031,
  //     0.38167886102443327,
  //     false,
  //     true,
  //     false
  //   ]);
  // });

  test('create without args', () async {
    final random1 = Xorshift64();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift64();

    expect([random1.nextRaw64(), random1.nextRaw64()],
        isNot([random2.nextRaw64(), random2.nextRaw64()]));
  });
}

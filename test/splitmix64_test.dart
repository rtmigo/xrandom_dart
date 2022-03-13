// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')
import 'package:test/test.dart';
import 'package:xrandom/src/50_splitmix64.dart';
import 'package:xrandom/xrandom.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Splitmix64(), ()=>Splitmix64.seeded());

  //print(-6562126107>>1);
  //return;

  checkReferenceFiles(() => Splitmix64(1), 'a');
  checkReferenceFiles(() => Splitmix64(0), 'b');
  checkReferenceFiles(() => Splitmix64(777), 'c');
  checkReferenceFiles(() => Splitmix64(int.parse('0xf7d3b43bed078fa3')), 'd');
  // checkReferenceFiles(() => Splitmix64(3141592653589793238), 'c');

  test('expected values', () {
    expect(expectedList(Splitmix64.seeded()), [
      int.parse('-1280933994267506231'),
      75710,
      0.9449949262451789,
      false,
      false,
      false
    ]);
  });

  test('create without args', () async {
    final random1 = Splitmix64();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Splitmix64();

    expect([random1.nextRaw64(), random1.nextRaw64()],
        isNot([random2.nextRaw64(), random2.nextRaw64()]));
  });
}

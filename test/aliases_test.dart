// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart'; // no imports for src should be here

void main() {



  test('Xrandom', () {
    expect(Xrandom(), isA<Xorshift32>());
    expect(Xrandom(1), isA<Xorshift32>());
    expect(Xrandom.expected(), isA<Xorshift32>());
    expect(Xrandom.expected(), isA<Xrandom>());
    expect(
        List.generate(3, (_) => Xrandom.expected().nextRaw32()),
        List.generate(3, (_) => Xorshift32.seeded().nextRaw32()));
    expect(
        List.generate(3, (_) => Xrandom(777).nextRaw32()),
        List.generate(3, (_) => Xorshift32(777).nextRaw32()));

    final r1 = Xrandom();
    final r2 = Xrandom();
    expect(
        List.generate(3, (_) => r1.nextRaw32()),
        isNot(List.generate(3, (_) => r2.nextRaw32())));
  });

  test('Xrandom readme expected', () {
    final random = Xrandom.expected();
    // you'll get same sequence of numbers every time
    expect(random.nextInt(1000), 925);
    expect(random.nextInt(1000), 686);
    expect(random.nextInt(1000), 509);
  });

  test('Xrandom readme 12345', () {
    final random = Xrandom(12345);
    // you'll get same sequence of numbers every time
    expect(random.nextInt(1000), 330);
    expect(random.nextInt(1000), 807);
    expect(random.nextInt(1000), 904);
  });



  void checkRespectsSeed(RandomBase32 Function(int seed) create) {
    expect( List.generate(3, (_) => create(123).nextRaw32()),
        List.generate(3, (_) => create(123).nextRaw32()) );
    expect( List.generate(3, (_) => create(123).nextRaw32()),
        isNot(List.generate(3, (_) => create(321).nextRaw32())) );
  }

  test('XrandomHq respects seed argument', () {
    checkRespectsSeed((seed) => Qrandom(seed));
  });

  test('Xrandom respects seed argument', () {
    checkRespectsSeed((seed) => Xrandom(seed));
  });


  test('XrandomHq returns constant values from seed', () {
    final random = Qrandom(10);
    expect( List.generate(3, (_) => random.nextRaw32()),
        [1282276250, 3989185767, 2009065675] );
  });

  test('XrandomHq range checking', () {
    expect(()=>Qrandom(0), throwsRangeError);
    expect(()=>Qrandom(0xFFFFFFFF+1), throwsRangeError);
  });


}

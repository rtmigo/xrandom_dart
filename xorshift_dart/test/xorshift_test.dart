// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT

import 'package:xorhift/xorshift.dart';
import "package:test/test.dart";

import 'data.dart';

String hex32(int x) => x.toRadixString(16).padLeft(8, '0').toUpperCase();

String hex64(XorShiftRandom xs) => hex32(xs.resU) + hex32(xs.resL);

void main() {
  test('Reference data: int 0102', () {
    final xf = XorShiftRandom([0, 1, 0, 2]);
    for (var expectedHex in ints12) {
      xf.step();
      expect(hex64(xf), expectedHex);
    }
  });

  test('Reference data: int 0304', () {
    final xf = XorShiftRandom([0, 3, 0, 4]);
    for (var expectedHex in ints34) {
      xf.step();
      expect(hex64(xf), expectedHex);
    }
  });

  test('Reference data: double 0102', () {
    final xf = XorShiftRandom([0, 1, 0, 2]);
    for (var expectedStr in double12) {
      double expected = double.parse(expectedStr);
      final result = xf.nextDouble();
      expect(result, expected);
    }
  });

  test('Reference data: double 0304', () {
    final xf = XorShiftRandom([0, 3, 0, 4]);
    for (var expectedStr in double34) {
      double expected = double.parse(expectedStr);
      final result = xf.nextDouble();
      expect(result, expected);
    }
  });

  test('nextDouble', ()
  {
    var r = XorShiftRandom([12,24,88,11]);

    for (int i=0; i<10000000; ++i)
    {
      var d = r.nextDouble();
      expect(d, greaterThanOrEqualTo(0.0));
      expect(d, lessThan(1.0));
    }
  });

  test('nextInt', ()
  {
    var r = XorShiftRandom([1111,2222,3333,4444]);//[199,88,77,66]);

    expect(
        List.generate(20, (index) => r.nextInt(26)),
        [0, 4, 21, 1, 9, 8, 25, 19, 19, 10, 13, 19, 21, 21, 22, 13, 4, 7, 2, 22]);
  });

  test('nextInt counts', ()
  {
    var r = XorShiftRandom([1111,2222,3333,4444]);

    final intToCount = Map<int,int>();


    for (int i=0; i<1000000; ++i) {
      var x = r.nextInt(10);
      expect(x, greaterThanOrEqualTo(0));
      expect(x, lessThan(10));
      intToCount[x] = (intToCount[x]??0)+1;
    }

    // see the the numbers are uniformly distributed
    expect(intToCount,
        {
          0: 100364,
          1: 99988,
          2: 100199,
          3: 99865,
          4: 100204,
          5: 99769,
          6: 99695,
          7: 99722,
          8: 100204,
          9: 99990,
        });
  });
}
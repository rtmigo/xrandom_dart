// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


@TestOn('vm')

import 'dart:io';

import "package:test/test.dart";

import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xorshift64.dart';
import 'package:xrandom/xrandom.dart';

// xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)
// 'xorshift128 (seed 5 23 42 777)'
// xorshift128 (seed 1 2 3 4)'

// 'xorshift128plus (seed 1 2)'
// 'xorshift128plus (seed 42 777)'
// 'xorshift128plus (seed 1081037251 1975530394)'

import 'helper.dart';

void main() {

  //print(0xFFFFFFFFFFFFFFFF);
  //print(0x9FFFFFFFFFFFFFFF);
  //return;

  testCommonRandom(()=>Xorshift64());

  // test("reference data", () {
  //   expect(
  //       referenceSignature('xorshift64 (seed 1)'),
  //       ['0000000040822041', '100041060c011441', '9b1e842f6e862629', '1a79f717c30cd499']);
  //   expect(
  //       referenceSignature('xorshift64 (seed 42)'),
  //       ['0000000a95514aaa', 'a00aaafdf80202bf', '8b13399cd1d1497a', '19534e6bc7e4c934']);
  //   expect(
  //       referenceSignature('xorshift64 (seed 3141592653589793238)'),
  //       ['366b2d97e95498c5', '9546626d41d0a0b4', 'e23e2b18a287acf5', 'd81ada3db94a4ee1']);
  //
  // });

  // test("seed 1", () {
  //   final random = Xorshift64(1);
  //   compareWithReference64(random, "xorshift64 (seed 1)");
  // });
  //
  // test('seed 42', () {
  //   final random = Xorshift64(42);
  //   compareWithReference64(random, "xorshift64 (seed 42)");
  // });
  //
  // test('seed 3141592653589793238', () {
  //   final random = Xorshift64(BigInt.parse('3141592653589793238').toInt());
  //   compareWithReference64(random, "xorshift64 (seed 3141592653589793238)");
  // });

  // test('predefined next', () {
  //   final random = Xorshift64.expected();
  //   expect(
  //       skipAndTake(()=>random.nextInt64().toHexUint64uc(), 5000, 3),
  //       ['A78D8BFA5E7260CA', '5DB7D12B9759F68B', 'ABD3D730279787A6']
  //   );
  // });

  checkReferenceFiles(()=>Xorshift64(1), 'a');
  checkReferenceFiles(()=>Xorshift64(42), 'b');
  checkReferenceFiles(()=>Xorshift64(3141592653589793238), 'c');

  test('expected values', () {
    expect(expectedList(Xorshift64.expected()),
        [int.parse('-6926213550972868430'), 40031, 0.38167886102443327, false, true, false]
    //    [1225539925, 51686, 0.40665327328483225, false, true, false]
    );
  });


    // test("doubles", () {
  //   //compareDoubles(Xorshift64(1), "xorshift64_a");
  // });

  // test("predefined double", () {
  //   final random = Xorshift64.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  //       [0.3090071651939921, 0.7321721518371331, 0.3424023614053875]
  //   );
  // });

  test("create without args", ()  async {
    final random1 = Xorshift64();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift64();

    expect(
        [random1.nextInt64(), random1.nextInt64()],
        isNot([random2.nextInt64(), random2.nextInt64()]));
  });
}

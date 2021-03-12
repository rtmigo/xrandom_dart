// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xorhift/ints.dart';
import 'package:xorhift/xorshift128.dart';
import 'package:xorhift/xorshift128plus.dart';

import 'helper.dart';
import 'reference.dart';
import 'madsen.dart';

void main() {
  test("reference data", () {
    // three first the numbers from the first sample must be the same as
    // https://github.com/AndreasMadsen/xorshift/blob/master/reference.json
    // (version 2021-03)
    expect(referenceSignature('xorshift128plus (seed 1 2)'),
        ['0000000000000003', '0000000000800025', '0000000002040083', 'fc1879e0c22c55d6']);

    // those are just random
    expect(referenceSignature('xorshift128plus (seed 42 777)'),
        ['0000000000000333', '0000000015000984', '00000001a6286adc', '336f5dcfc0e530d0']);
    expect(referenceSignature('xorshift128plus (seed 8378522730901710845 1653112583875186020)'),
        ['8b37872b3d8a7561', '7d171d4b597b258d', '48b7d5d5301ad113', '5ee29237a2f00ae7']);
  });

  test("compare reference data to madsen", () {
    // here we comparing the reference results from the
    // https://github.com/AndreasMadsen/xorshift/blob/master/reference.json
    // to our reference data. Just to be sure, that the reference data is ok

    final madsen = madsenSample["integer"]!["1-2"]!;
    final ours = referenceData['xorshift128plus (seed 1 2)']!;

    for (int i = 0; i < madsen.length; ++i) expect(ours[i].toUpperCase(), madsen[i]);
  });

  test("seed A", () {
    final random = Xorshift128PlusRandom(1, 2);
    compareWithReference(random, 'xorshift128plus (seed 1 2)');
  });

  test("seed B", () {
    final random = Xorshift128PlusRandom(42, 777);
    compareWithReference(random, 'xorshift128plus (seed 42 777)');
  });

  test("seed C", () {
    final random = Xorshift128PlusRandom(8378522730901710845, 1653112583875186020);
    compareWithReference(random, 'xorshift128plus (seed 8378522730901710845 1653112583875186020)');
  });

  test("doubles", () => checkDoubles(Xorshift128PlusRandom(42, 777)));
  test("bools", () => checkBools(Xorshift128PlusRandom(42, 777)));
  test("ints", () => checkInts(Xorshift128PlusRandom(42, 777)));
  //
  // test("predefined next", () {
  //   final random = Xorshift128Random.deterministic();
  //   expect(
  //       skipAndTake(()=>random.next().toHexUint32(), 5000, 3),
  //       ['682C4EE4', '208190FD', '455F4A85']
  //   );
  // });
  //
  // test("predefined double", () {
  //   final random = Xorshift128Random.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  //       [0.40692608882834347, 0.12697702556079649, 0.27098527650138954]
  //   );
  // });
}

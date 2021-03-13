// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import "package:test/test.dart";
import 'package:xorhift/src/ints.dart';
import 'package:xorhift/src/xorshift128.dart';
import 'package:xorhift/src/xorshift128plus.dart';

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
    final random = Xorshift128Plus(1, 2);
    compareWithReference(random, 'xorshift128plus (seed 1 2)');
  });

  test("seed B", () {
    final random = Xorshift128Plus(42, 777);
    compareWithReference(random, 'xorshift128plus (seed 42 777)');
  });

  test("seed C", () {
    final random = Xorshift128Plus(8378522730901710845, 1653112583875186020);
    compareWithReference(random, 'xorshift128plus (seed 8378522730901710845 1653112583875186020)');
  });

  test("doubles", () => checkDoubles(Xorshift128Plus(42, 777)));
  test("bools", () => checkBools(Xorshift128Plus(42, 777)));
  test("ints", () => checkInts(Xorshift128Plus(42, 777)));

  test("predefined next", () {
    final random = Xorshift128Plus.deterministic();
    expect(
        skipAndTake(()=>random.next().toHexUint64(), 5000, 3),
        ['1F1CCFAF5A83DC2A', 'AE8708051CB834DF', '897E4E4BA735BC15']
    );
  });

  test("predefined double", () {
    final random = Xorshift128Plus.deterministic();

    // check the first values are not zeroes
    expect(
        skipAndTake(()=>random.nextDouble(), 0, 3),
        [0.5438160400931709, 0.4886339482268167, 0.28405510382445276]
    );

    expect(
        skipAndTake(()=>random.nextDouble(), 5000, 3),
        [0.9056777920011874, 0.530136740954974, 0.7211288399533309]
    );
  });


  test("madsen double", () {

    final madsen = madsenSample["double"]!["1-2"]!;
    final random = Xorshift128Plus(1, 2);

    for (String expectedStr in madsen)
      expect(random.nextDouble(), double.parse(expectedStr));

  });
}

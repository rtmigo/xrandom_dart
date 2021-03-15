// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


@TestOn('vm')

import "package:test/test.dart";
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xorshift128plus.dart';

import 'helper.dart';
import 'madsen.dart';

void main() {
  // test("reference data", () {
  //   // three first the numbers from the first sample must be the same as
  //   // https://github.com/AndreasMadsen/xorshift/blob/master/reference.json
  //   // (version 2021-03)
  //   expect(referenceSignature('xorshift128plus (seed 1 2)'),
  //       ['0000000000000003', '0000000000800025', '0000000002040083', 'fc1879e0c22c55d6']);
  //
  //   // those are just random
  //   expect(referenceSignature('xorshift128plus (seed 42 777)'),
  //       ['0000000000000333', '0000000015000984', '00000001a6286adc', '336f5dcfc0e530d0']);
  //   expect(referenceSignature('xorshift128plus (seed 8378522730901710845 1653112583875186020)'),
  //       ['8b37872b3d8a7561', '7d171d4b597b258d', '48b7d5d5301ad113', '5ee29237a2f00ae7']);
  // });

  // test("compare reference data to madsen", () {
  //   // here we comparing the reference results from the
  //   // https://github.com/AndreasMadsen/xorshift/blob/master/reference.json
  //   // to our reference data. Just to be sure, that the reference data is ok
  //
  //   final madsen = madsenSample["integer"]!["1-2"]!;
  //   final ours = referenceData['xorshift128plus (seed 1 2)']!;
  //
  //   for (int i = 0; i < madsen.length; ++i) expect(ours[i].toUpperCase(), madsen[i]);
  // });

  // test("seed A", () {
  //   final random = Xorshift128p(1, 2);
  //   compareWithReference64(random, 'xorshift128plus (seed 1 2)');
  // });
  //
  // test("seed B", () {
  //   final random = Xorshift128p(42, 777);
  //   compareWithReference64(random, 'xorshift128plus (seed 42 777)');
  // });
  //
  // test("seed C", () {
  //   final random = Xorshift128p(8378522730901710845, 1653112583875186020);
  //   compareWithReference64(random, 'xorshift128plus (seed 8378522730901710845 1653112583875186020)');
  // });

  testCommonRandom(()=>Xorshift128p());

  // test('predefined next', () {
  //   final random = Xorshift128p.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextInt64().toHexUint64uc(), 5000, 3),
  //       ['1F1CCFAF5A83DC2A', 'AE8708051CB834DF', '897E4E4BA735BC15']
  //   );
  // });

  // test("predefined double", () {
  //   final random = Xorshift128p.deterministic();
  //
  //   // check the first values are not zeroes
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 0, 3),
  //       [0.5438160400931709, 0.4886339482268167, 0.28405510382445276]
  //   );
  //
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  //       [0.9056777920011874, 0.530136740954974, 0.7211288399533309]
  //   );
  // });

  checkReferenceFiles(()=>Xorshift128p(1,2), 'a');
  checkReferenceFiles(()=>Xorshift128p(42, 777), 'b');
  checkReferenceFiles(()=>Xorshift128p(8378522730901710845, 1653112583875186020), 'c');

  test('expected values', () {
    expect(expectedList(Xorshift128p.expected()),
        [int.parse('8256696158060995935'), 27312, 0.04017928972328655, false, true, false]
      //    [1225539925, 51686, 0.40665327328483225, false, true, false]
    );
  });


  test("madsen double", () {

    final madsen = madsenSample["double"]!["1-2"]!;
    final random = Xorshift128p(1, 2);

    for (String expectedStr in madsen)
      expect(random.nextDoubleMemcast(), double.parse(expectedStr));

  });

  test("create without args", ()  async {
    final random1 = Xorshift128p();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift128p();

    expect(
        [random1.nextInt64(), random1.nextInt64()],
        isNot([random2.nextInt64(), random2.nextInt64()]));
  });

  // test("deterministic", ()  async {
  //   final random1 = Xorshift128Plus.deterministic();
  //
  //   expect(random1.nextInt(1000), 543);
  //   expect(random1.nextInt(1000), 488);
  //   expect(random1.nextInt(1000), 284);
  // });
}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import "package:test/test.dart";
import 'package:xorshift/src/00_ints.dart';
import 'package:xorshift/src/xoshiro128pp.dart';

// xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)
// 'xorshift128 (seed 5 23 42 777)'
// 'xorshift128 (seed 1 2 3 4)'

import 'helper.dart';
import 'reference.dart';

void main() {

  //print(unsignedRightShiftCode("x","32-k"));
  //return;

  // xoshiro128++ (seed 00000001 00000002 00000003 00000004)
  // xoshiro128++ (seed 406f51c3 75c0339a b060cf5c 5e24acc6)
  // xoshiro128++ (seed 00000005 00000017 0000002a 00000309)

  // test("reference data", () {
  //   expect(
  //       referenceSignature("xoshiro128++ (seed 00000001 00000002 00000003 00000004)"),
  //       ['00002025', '0000383e', '0000282c', '2ee0065b']);
  //   // expect(
  //   //     referenceSignature("xorshift128 (seed 5 23 42 777)"),
  //   //     ['00185347', '0019023e', '0019ba92', '91050530']);
  //   // expect(
  //   //     referenceSignature("xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)"),
  //   //     ['3b568794', '8dfab58d', 'f9d21b4b', '4b5d88e5']);
  //
  // });

  test("seed A", () {
    final random = Xoshiro128pp(1, 2, 3, 4);
    compareWithReference32(random, "xoshiro128++ (seed 00000001 00000002 00000003 00000004)");
  });

  test("seed B", () {
    final random = Xoshiro128pp(5, 23, 42, 777);
    compareWithReference32(random, "xoshiro128++ (seed 00000005 00000017 0000002a 00000309)");
  });
  //
  test("seed C", () {
    final random = Xoshiro128pp(1081037251, 1975530394, 2959134556, 1579461830);
    compareWithReference32(random, "xoshiro128++ (seed 406f51c3 75c0339a b060cf5c 5e24acc6)");
  });




  testCommonRandom(()=>Xoshiro128pp());
  //
  // test("predefined next", () {
  //   final random = Xoshiro128.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextInt32().toHexUint32(), 5000, 3),
  //       ['682C4EE4', '208190FD', '455F4A85']
  //   );
  // });
  //
  // // test("predefined double", () {
  // //   final random = Xorshift128.deterministic();
  // //   expect(
  // //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  // //       [0.8217153680630882, 0.16883535742482325, 0.2059260621445983]
  // //   );
  // // });
  //
  // test("create without args", ()  async {
  //   final random1 = Xoshiro128();
  //   await Future.delayed(Duration(milliseconds: 2));
  //   final random2 = Xorshift128();
  //
  //   expect(
  //       [random1.nextInt32(), random1.nextInt32()],
  //       isNot([random2.nextInt32(), random2.nextInt32()]));
  // });

}

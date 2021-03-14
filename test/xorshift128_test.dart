// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import "package:test/test.dart";
import 'package:xorshift/src/ints.dart';
import 'package:xorshift/src/xorshift128.dart';

// xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)
// 'xorshift128 (seed 5 23 42 777)'
// 'xorshift128 (seed 1 2 3 4)'

import 'helper.dart';
import 'reference.dart';

void main() {

  test("reference data", () {
    expect(
        referenceSignature("xorshift128 (seed 1 2 3 4)"),
        ['00002025', '0000383e', '0000282c', '2ee0065b']);
    expect(
        referenceSignature("xorshift128 (seed 5 23 42 777)"),
        ['00185347', '0019023e', '0019ba92', '91050530']);
    expect(
        referenceSignature("xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)"),
        ['3b568794', '8dfab58d', 'f9d21b4b', '4b5d88e5']);

  });

  test("seed A", () {
    final random = Xorshift128(1, 2, 3, 4);
    compareWithReference32(random, "xorshift128 (seed 1 2 3 4)");
  });

  test("seed B", () {
    final random = Xorshift128(5, 23, 42, 777);
    compareWithReference32(random, "xorshift128 (seed 5 23 42 777)");
  });

  test("seed C", () {
    final random = Xorshift128(1081037251, 1975530394, 2959134556, 1579461830);
    compareWithReference32(random, "xorshift128 (seed 1081037251 1975530394 2959134556 1579461830)");
  });




  testCommonRandom(Xorshift128.deterministic());

  test("predefined next", () {
    final random = Xorshift128.deterministic();
    expect(
        skipAndTake(()=>random.next32().toHexUint32(), 5000, 3),
        ['682C4EE4', '208190FD', '455F4A85']
    );
  });

  // test("predefined double", () {
  //   final random = Xorshift128.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  //       [0.8217153680630882, 0.16883535742482325, 0.2059260621445983]
  //   );
  // });

  test("create without args", ()  async {
    final random1 = Xorshift128();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift128();

    expect(
        [random1.next32(), random1.next32()],
        isNot([random2.next32(), random2.next32()]));
  });

}

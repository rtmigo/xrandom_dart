// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import "package:test/test.dart";
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xorshift32.dart';

import 'helper.dart';

void main() {

  testCommonRandom(()=>Xorshift32());

  // test("reference data", () {
  //   expect(
  //       referenceSignature("xorshift32 (seed 1)"),
  //       ['00042021', '04080601', '9dcca8c5', '7c43326e']);
  //   expect(
  //       referenceSignature("xorshift32 (seed 42)"),
  //       ['00ad4528', 'a90a34ac', '1c67af03', '7478bd43']);
  //   expect(
  //       referenceSignature("xorshift32 (seed 314159265)"),
  //       ['b11ddc17', '59781258', '3d54c7e1', '8d87618b']);
  //
  // });

  // test("seed 1", () {
  //   final random = Xorshift32(1);
  //   compareWithReference32(random, "xorshift32 (seed 1)");
  // });
  //
  // test("seed 42", () {
  //   final random = Xorshift32(42);
  //   compareWithReference32(random, "xorshift32 (seed 42)");
  // });
  //
  // test("seed 314159265", () {
  //   final random = Xorshift32(314159265);
  //   compareWithReference32(random, "xorshift32 (seed 314159265)");
  // });

  checkReferenceFiles(()=>Xorshift32(1), 'a');
  checkReferenceFiles(()=>Xorshift32(42), 'b');
  checkReferenceFiles(()=>Xorshift32(314159265), 'c');



  // test("doubles", ()=>checkDoubles(Xorshift32(777)));
  // test("bools", ()=>checkBools(Xorshift32(777)));
  // test("ints", ()=>checkInts(Xorshift32(777)));

  test("predefined next", () {
    final random = Xorshift32.deterministic();
    expect(
        skipAndTake(()=>random.nextInt32().toHexUint32uc(), 5000, 3),
        ['62982C53', '855D849A', '8C1511DD']
    );
  });

  test("expected nextInt", () {
    final random = Xorshift32.deterministic();
    expect(
        skipAndTake(()=>random.nextInt(1000), 0, 3),
        [119, 240, 369]
    );
  });

  // test("predefined double", () {
  //   final random = Xorshift32.deterministic();
  //   expect(
  //       skipAndTake(()=>random.nextDouble(), 5000, 3),
  //       [0.2990539312680619, 0.624981467496995, 0.8814333835274933]
  //   );
  // });

  test("create without args", ()  async {
    final random1 = Xorshift32();
    await Future.delayed(Duration(milliseconds: 2));
    final random2 = Xorshift32();

    expect(
        [random1.nextInt32(), random1.nextInt32()],
        isNot([random2.nextInt32(), random2.nextInt32()]));
  });
}

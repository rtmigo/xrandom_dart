// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xorhift/ints.dart';
import 'package:xorhift/xorshift32.dart';

import 'helper.dart';
import 'reference.dart';

void main() {

  test("reference data", () {
    expect(
        referenceSignature("xorshift32 (seed 23)"),
        ['005ee2d6', '5c8dd654', 'a5f9cb9f', '14f18cc3']);
    expect(
        referenceSignature("xorshift32 (seed 42)"),
        ['00ad4528', 'a90a34ac', 'd970c3c0', '7478bd43']);
    expect(
        referenceSignature("xorshift32 (seed 777)"),
        ['0c454419', '3c00f93a', '1c1122b8', 'a6015c95']);

  });

  test("seed 23", () {
    final random = XorShift32(23);
    compareWithReference32(random, "xorshift32 (seed 23)");
  });

  test("seed 42", () {
    final random = XorShift32(42);
    compareWithReference32(random, "xorshift32 (seed 42)");
  });

  test("seed 777", () {
    final random = XorShift32(777);
    compareWithReference32(random, "xorshift32 (seed 777)");
  });

  test("doubles", ()=>checkDoubles(XorShift32(777)));
  test("bools", ()=>checkBools(XorShift32(777)));
  test("ints", ()=>checkInts(XorShift32(777)));

  test("predefined next", () {
    final random = XorShift32(42);
    expect(
        skipAndTake(()=>random.next().toHexUint32(), 5000, 3),
        ['BCFAE4D7', 'EC6EE807', '1CAC06B0']
    );
  });

  test("predefined double", () {
    final random = XorShift32(42);
    expect(
        skipAndTake(()=>random.nextDouble(), 5000, 3),
        [0.7382033373550986, 0.9235672969193122, 0.11199991035088895]
    );
  });

}

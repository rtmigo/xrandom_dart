// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

@TestOn('vm')

import "package:test/test.dart";

import 'package:xrandom/src/00_ints.dart';

void main() {



  // print(0x7FFFFFFFFFFFFFFF);
  // print(pow(2, 63));
  // print(1<<63);

  test('string to int', () {
    // the problem with BigInt.toInt():
    expect(BigInt.parse('0xf7d3b43bed078fa3').toInt().toHexUint64(),
        '7fffffffffffffff');
  });

  test("are we", () {
    expect(INT64_SUPPORTED, true);
  });

  test("lower32", () {
    expect(0x9876543277755111.lower32(), 0x77755111);
    expect(0x9876543201234567.lower32(), 0x01234567);
  });

  test("higher32", () {
    expect(0x9876543277755111.higher32(), 0x98765432);
    expect(0xFFFFFFFFFFFFFFFF.higher32(), 0xFFFFFFFF);
  });

  test("hex", () {
    expect(0xFF.toHexUint32uc(), "000000FF");
    expect(0xFF.toHexUint64uc(), "00000000000000FF");
    expect(0xFFFFFFFFFFFFFFFF.toHexUint64uc(), "FFFFFFFFFFFFFFFF");
    expect(0x9FFFFFFFFFFFFFFF.toHexUint64uc(), "9FFFFFFFFFFFFFFF");
    expect((-1).toHexUint64uc(), "FFFFFFFFFFFFFFFF");
    expect((-6917529027641081857).toHexUint64uc(), "9FFFFFFFFFFFFFFF");
  });

  test("signedRightShift", () {
    expect(0xFF.unsignedRightShift(4), 0xF);
    expect(0x9FFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64uc(),
        "09FFFFFFFFFFFFFF");
    expect(0xFFFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64uc(),
        "0FFFFFFFFFFFFFFF");
  });

  test("uint32 to int32", () {
    // 0x7ffffffd 2147483645 -> 2147483645
    // 0x7ffffffe 2147483646 -> 2147483646
    // 0x7fffffff 2147483647 -> 2147483647
    // 0x80000000 2147483648 -> -2147483648
    // 0x80000001 2147483649 -> -2147483647
    // 0x80000002 2147483650 -> -2147483646

    expect(0x7ffffffd.uint32_to_int32(), 2147483645);
    expect(0x7ffffffe.uint32_to_int32(), 2147483646);
    expect(0x7fffffff.uint32_to_int32(), 2147483647);
    expect(0x80000000.uint32_to_int32(), -2147483648);
    expect(0x80000001.uint32_to_int32(), -2147483647);
    expect(0x80000002.uint32_to_int32(), -2147483646);
  });
}

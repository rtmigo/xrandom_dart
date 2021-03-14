// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


@TestOn('vm')

import "package:test/test.dart";

import 'package:xrandom/src/00_ints.dart';

void main() {

  //print(0xFFFFFFFFFFFFFFFF.unsignedRightShift(31).toHexUint64());

  //return;

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

    expect(0xFF.toHexUint32(), "000000FF");
    expect(0xFF.toHexUint64(), "00000000000000FF");
    expect(0xFFFFFFFFFFFFFFFF.toHexUint64(), "FFFFFFFFFFFFFFFF");
    expect(0x9FFFFFFFFFFFFFFF.toHexUint64(), "9FFFFFFFFFFFFFFF");

  });

  test("signedRightShift", () {

    expect(0xFF.unsignedRightShift(4), 0xF);
    expect(0x9FFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64(), "09FFFFFFFFFFFFFF");
    expect(0xFFFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64(), "0FFFFFFFFFFFFFFF");

  });
}

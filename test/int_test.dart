// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

@TestOn('vm')

import "package:test/test.dart";

import 'package:xorshift/src/ints.dart';

void main() {

  test("are we", () {
    expect(INT64_SUPPORTED, true);
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

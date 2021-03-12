// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT


import "package:test/test.dart";

import 'package:xorhift/ints.dart';

void main() {
  test("hex", () {

    expect(0xFF.toHexUint32(), "000000FF");
    expect(0xFF.toHexUint64(), "00000000000000FF");
    expect(0xFFFFFFFFFFFFFFFF.toHexUint64(), "FFFFFFFFFFFFFFFF");
    expect(0x9FFFFFFFFFFFFFFF.toHexUint64(), "9FFFFFFFFFFFFFFF");

  });
}

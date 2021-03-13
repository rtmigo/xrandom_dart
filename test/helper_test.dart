// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause


import "package:test/test.dart";
import 'package:xorhift/src/ints.dart';

import 'helper.dart';

void main() {
  test("test", () {
    expect(trimLeadingZeros(""), "");
    expect(trimLeadingZeros("1"), "1");
    expect(trimLeadingZeros("01"), "1");
    expect(trimLeadingZeros("0001"), "1");
    expect(trimLeadingZeros("00004242"), "4242");
  });
}

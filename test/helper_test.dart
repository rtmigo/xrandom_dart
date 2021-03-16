// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import "package:test/test.dart";
import 'package:xrandom/src/00_ints.dart';

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

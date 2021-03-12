// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail
// SPDX-License-Identifier: MIT


import "package:test/test.dart";
import 'package:xorhift/ints.dart';
import 'package:xorhift/xorshift32.dart';

import 'helper.dart';
import 'reference.dart';

void main() {

  test("test", () {
    expect(trimLeadingZeros(""),"");
    expect(trimLeadingZeros("1"),"1");
    expect(trimLeadingZeros("01"),"1");
    expect(trimLeadingZeros("0001"),"1");
    expect(trimLeadingZeros("00004242"),"4242");
  });



}

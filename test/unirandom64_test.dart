// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

@TestOn('vm')

import 'dart:io';

import "package:test/test.dart";
import 'package:xorshift/src/ints.dart';
import 'package:xorshift/src/xorshift64.dart';

import 'helper.dart';
import 'reference.dart';

void main() {



  test("next32 returning parts of next64", () {

    final random1 = Xorshift64.deterministic();
    int a64 = random1.next64();
    int b64 = random1.next64();

    final random2 = Xorshift64.deterministic();
    expect(random2.next32(), a64.lower32());
    expect(random2.next32(), a64.higher32());
    expect(random2.next32(), b64.lower32());
    expect(random2.next32(), b64.higher32());
  });

}

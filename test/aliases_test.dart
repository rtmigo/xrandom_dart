// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';

void main() {

  test('Xrandom', () {

    expect(Xrandom() is Xorshift32, true);
    expect(Xrandom(1) is Xorshift32, true);
    expect(Xrandom.expected() is Xorshift32, true);

  });



}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';

void main() {
  test('Xrandom64', () {
    expect(Xrandom() is Xorshift128p, true);
    expect(Xrandom(1, 2) is Xorshift128p, true);
    expect(Xrandom.expected() is Xorshift128p, true);
  });
}

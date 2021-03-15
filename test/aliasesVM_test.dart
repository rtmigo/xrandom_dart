// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

@TestOn('vm')

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';

void main() {

  test('Xrandom64', () {

    expect(Xrandom64() is Xorshift128p, true);
    expect(Xrandom64(1,2) is Xorshift128p, true);
    expect(Xrandom64.expected() is Xorshift128p, true);

  });
}

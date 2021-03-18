// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@TestOn('vm')

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';

void main() {

  test('XrandomHq', () {
    expect(XrandomHq() is Xoshiro256pp, true);
    expect(XrandomHq(1) is Xoshiro256pp, true);
    expect(XrandomHq.expected() is Xoshiro256pp, true);
    expect(XrandomHq.expected() is XrandomHq, true);
    expect(
        List.generate(3, (_) => XrandomHq.expected().nextRaw32()),
        List.generate(3, (_) => Xoshiro256pp.expected().nextRaw32()));

    final r1 = XrandomHq();
    final r2 = XrandomHq();
    expect(
        List.generate(3, (_) => r1.nextRaw64()),
        isNot(List.generate(3, (_) => r2.nextRaw64())));
  });

}

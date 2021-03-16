// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';

void main() {
  test('Xrandom', () {
    expect(Xrandom() is Xorshift32, true);
    expect(Xrandom(1) is Xorshift32, true);
    expect(Xrandom.expected() is Xorshift32, true);
    expect(Xrandom.expected() is Xrandom, true);
    expect(
        List.generate(3, (_) => Xrandom.expected().nextInt32()),
        List.generate(3, (_) => Xorshift32.expected().nextInt32()));
    expect(
        List.generate(3, (_) => Xrandom(777).nextInt32()),
        List.generate(3, (_) => Xorshift32(777).nextInt32()));

    final r1 = Xrandom();
    final r2 = Xrandom();
    expect(
        List.generate(3, (_) => r1.nextInt32()),
        isNot(List.generate(3, (_) => r2.nextInt32())));
  });

  test('XrandomHqJs', () {
    expect(XrandomHqJs() is Xoshiro128pp, true);
    expect(XrandomHqJs(1) is Xoshiro128pp, true);
    expect(XrandomHqJs.expected() is Xoshiro128pp, true);
    expect(XrandomHqJs.expected() is XrandomHqJs, true);
    expect(
        List.generate(3, (_) => XrandomHqJs.expected().nextInt32()),
        List.generate(3, (_) => Xoshiro128pp.expected().nextInt32()));

    final r1 = XrandomHqJs();
    final r2 = XrandomHqJs();
    expect(
        List.generate(3, (_) => r1.nextInt32()),
        isNot(List.generate(3, (_) => r2.nextInt32())));
  });
}

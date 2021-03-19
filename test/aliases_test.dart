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
        List.generate(3, (_) => Xrandom.expected().nextRaw32()),
        List.generate(3, (_) => Xorshift32.expected().nextRaw32()));
    expect(
        List.generate(3, (_) => Xrandom(777).nextRaw32()),
        List.generate(3, (_) => Xorshift32(777).nextRaw32()));

    final r1 = Xrandom();
    final r2 = Xrandom();
    expect(
        List.generate(3, (_) => r1.nextRaw32()),
        isNot(List.generate(3, (_) => r2.nextRaw32())));
  });

  test('Xrandom readme expected', () {
    final random = Xrandom.expected();
    // you'll get same sequence of numbers every time
    expect(random.nextInt(1000), 925);
    expect(random.nextInt(1000), 686);
    expect(random.nextInt(1000), 509);
  });

  test('Xrandom readme 12345', () {
    final random = Xrandom(12345);
    // you'll get same sequence of numbers every time
    expect(random.nextInt(1000), 330);
    expect(random.nextInt(1000), 807);
    expect(random.nextInt(1000), 904);
  });


  test('XrandomHqJs', () {
    expect(XrandomHqJs() is Xoshiro128pp, true);
    expect(XrandomHqJs(1) is Xoshiro128pp, true);
    expect(XrandomHqJs.expected() is Xoshiro128pp, true);
    expect(XrandomHqJs.expected() is XrandomHqJs, true);
    expect(
        List.generate(3, (_) => XrandomHqJs.expected().nextRaw32()),
        List.generate(3, (_) => Xoshiro128pp.expected().nextRaw32()));

    final r1 = XrandomHqJs();
    final r2 = XrandomHqJs();
    expect(
        List.generate(3, (_) => r1.nextRaw32()),
        isNot(List.generate(3, (_) => r2.nextRaw32())));
  });
}

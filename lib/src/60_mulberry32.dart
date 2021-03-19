// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/00_ints.dart';

import 'package:xrandom/src/21_base32.dart';

/// Random number generator based on **mulberry32** algorithm by T. Ettinger (2017).
/// The reference implementation in C can be found in
/// <https://gist.github.com/tommyettinger/46a874533244883189143505d203312c>.
class Mulberry32 extends RandomBase32 {
  Mulberry32([int? seed32]) {
    if (seed32 != null) {
      RangeError.checkValueInInterval(seed32, 0, 0xFFFFFFFF);
      _x = seed32;
    } else {
      _x = (DateTime.now().millisecondsSinceEpoch ^ hashCode) & 0xFFFFFFFF;
    }
  }
  late int _x;

  static const defaultSeed = 0xd9e2fcc8;

  static Mulberry32 expected() => Mulberry32(defaultSeed);

  @override
  int nextRaw32() {

    _x += 0x6D2B79F5;
    _x &= 0xFFFFFFFF;
    //print('A: $_x');

    int z = _x;
    z = ((z ^ (z>>15))) * (z | 1) ;

    z&=0xFFFFFFFF;
    //print('B: $z');
    z ^= z + (z ^ (z>>7)) * (z | 61);

    z&=0xFFFFFFFF;
    //print('C: $z');
    final result =  z ^ (z>>14);
    //print('D: $result');
    return result;
  }
}

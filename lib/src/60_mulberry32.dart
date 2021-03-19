// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/21_base32.dart';

/// Random number generator based on **mulberry32** algorithm by T. Ettinger (2017).
/// The reference implementation in C can be found in <https://git.io/JmoUq>.
class Mulberry32 extends RandomBase32 {
  Mulberry32([int? seed32]) {
    if (seed32 != null) {
      RangeError.checkValueInInterval(seed32, 0, 0xFFFFFFFF);
      _state = seed32;
    } else {
      _state = (DateTime.now().millisecondsSinceEpoch ^ hashCode) & 0xFFFFFFFF;
    }
  }

  late int _state;

  static const defaultSeed = 0xd9e2fcc8;

  static Mulberry32 expected() => Mulberry32(defaultSeed);

  @override
  int nextRaw32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    int z = _state;
    z = (((z ^ (z >> 15))) * (z | 1)) & 0xFFFFFFFF;  // does not work on JS!
    z ^= z + (z ^ (z >> 7)) * (z | 61);
    z &= 0xFFFFFFFF;
    return z ^ (z >> 14);
  }
}

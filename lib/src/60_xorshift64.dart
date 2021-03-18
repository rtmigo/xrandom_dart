// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/21_base32.dart';
import 'package:xrandom/src/50_splitmix64.dart';

import '00_errors.dart';
import '00_ints.dart';
import '21_base64.dart';

/// Random number generator based on **xorshift64** algorithm by G. Marsaglia (2003).
/// The reference implementation in C can be found in
/// <https://www.jstatsoft.org/article/view/v008i14>.
class Xorshift64 extends RandomBase64 {
  static final _defaultSeed = int.parse('0x76a5c5b65ce8677c');

  Xorshift64([seed]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (seed != null) {
      if (seed == 0) {
        throw RangeError('The seed must be greater than 0.');
      }
      _state = seed;
    } else {
      _state = Splitmix64.instance.nextRaw64();
    }
  }

  late int _state;

  @override
  int nextRaw64() {
    // algorithm from p.4 of "Xorshift RNGs"
    // by George Marsaglia, 2003
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift

    var x = _state;
    x ^= x << 13;
    // V1: x ^= x.unsignedRightShift(7);
    // V2: x ^= x >= 0 ? x >> 7 : ((x & INT64_MAX_POSITIVE) >> 7) | (1 << (63 - 7));
    x ^= (x >> 7) & ~(-1 << (64 - 7));
    x ^= x << 17;
    return _state = x;
  }

  static Xorshift64 expected() {
    return Xorshift64(_defaultSeed);
  }
}

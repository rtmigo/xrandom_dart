// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/seeding.dart';
import 'package:xrandom/src/splitmix64.dart';

import '00_errors.dart';
import '00_ints.dart';
import 'package:xrandom/src/10_random_base.dart';

/// Random number generator based on `xorshift128+` algorithm by S.Vigna (2015).
/// The reference implementation in C can be found in <https://arxiv.org/abs/1404.0390> (V3).
class Xorshift128p extends RandomBase64 {
  Xorshift128p([int? seedA, int? seedB]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (seedA != null || seedB != null) {

      if (seedA==null) {
        throw ArgumentError.notNull('a');
      }
      if (seedB==null) {
        throw ArgumentError.notNull('b');
      }

      _S0 = seedA;
      _S1 = seedB;

      if (seedA == 0 && seedB == 0) {
        throw ArgumentError('The seed should not consist of only zeros..');
      }
    } else {
      // just creating a mess
      _S0 = Splitmix64.instance.nextInt64();
      _S1 = Splitmix64.instance.nextInt64();
    }
  }

  late int _S0, _S1;

  int nextInt64() {
    // algorithm from "Further scramblings of Marsaglia’s xorshift generators"
    // by Sebastiano Vigna
    //
    // https://arxiv.org/abs/1404.0390 [v2] Mon, 14 Dec 2015 - page 6
    // https://arxiv.org/abs/1404.0390 [v3] Mon, 23 May 2016 - page 6

    var s1 = _S0;
    final s0 = _S1;
    final result = s0 + s1;
    _S0 = s0;
    s1 ^= s1 << 23; // a

    // C: _S1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
    // DartV1: _S1 = s1 ^ s0 ^ (s1.unsignedRightShift(18)) ^ (s0.unsignedRightShift(5)); // b, c

    _S1 = s1 ^
        s0 ^
        ( // V1: s1.unsignedRightShift(18)
            // V2: s1 >= 0 ? s1 >> 18 : ((s1 & INT64_MAX_POSITIVE) >> 18) | (1 << (63 - 18))
            (s1 >> 18) & ~(-1 << (64 - 18))) ^
        ( // V1: s0.unsignedRightShift(5)
            // V2: s0 >= 0 ? s0 >> 5 : ((s0 & INT64_MAX_POSITIVE) >> 5) | (1 << (63 - 5))
            (s0 >> 5) & ~(-1 << (64 - 5))); // b, c

    return result;
  }

  static final int _deterministicSeedA = int.parse('0x0ad1ea48a354036c');
  static final int _deterministicSeedB = int.parse('0x67c3c3204c3ae1f3');

  static Xorshift128p expected() {
    return Xorshift128p(_deterministicSeedA, _deterministicSeedB);
  }
}

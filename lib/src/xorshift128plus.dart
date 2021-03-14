// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xorshift/src/seeding.dart';

import '00_errors.dart';
import '00_ints.dart';
import 'package:xorshift/src/10_random_base.dart';

/// Random number generator based on `xorshift128+` algorithm by S.Vigna (2015).
/// The reference implementation in C can be found in <https://arxiv.org/abs/1404.0390> (V3).
class Xorshift128Plus extends RandomBase64 {
  Xorshift128Plus([int? a, int? b]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (a != null || b != null) {
      this._S0 = a!;
      this._S1 = b!;
      if (a == 0 && b == 0) {
        throw ArgumentError("The seed should not consist of only zeros..");
      }
    } else {
      final now = DateTime.now().microsecondsSinceEpoch;
      // just creating a mess
      this._S0 = mess2to64A(now, this.hashCode);
      this._S1 = mess2to64B(now, this.hashCode);
    }
  }

  late int _S0, _S1;

  int nextInt64() {
    // algorithm from "Further scramblings of Marsaglia’s xorshift generators"
    // by Sebastiano Vigna
    //
    // https://arxiv.org/abs/1404.0390 [v2] Mon, 14 Dec 2015 - page 6
    // https://arxiv.org/abs/1404.0390 [v3] Mon, 23 May 2016 - page 6

    int s1 = _S0;
    final int s0 = _S1;
    final int result = s0 + s1;
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

  @override
  double nextDouble() {
    int x = this.nextInt64();

    // in C, this is implemented by casting the memory area to the double type.
    // This is not an option here

    // const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
    // return *((double *) &x_doublefied) - 1.0;

    // so we just reimplement it like here
    // https://github.com/AndreasMadsen/xorshift/blob/master/xorshift.js

    int resL = x & 0xffffffff;
    //int resU = x.unsignedRightShift(32);
    int resU = x >= 0 ? x >> 32 : ((x & INT64_MAX_POSITIVE) >> 32) | (1 << (63 - 32));

    return resU * 2.3283064365386963e-10 + (resL >> 12) * 2.220446049250313e-16;
  }

  static final int _deterministicSeedA = BigInt.parse("8378522730901710845").toInt();
  static final int _deterministicSeedB = BigInt.parse("1653112583875186020").toInt();

  static Xorshift128Plus deterministic() {
    return Xorshift128Plus(_deterministicSeedA, _deterministicSeedB);
  }
}

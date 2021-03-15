// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xrandom/src/seeding.dart';

import '00_errors.dart';
import '00_ints.dart';
import 'package:xrandom/src/10_random_base.dart';

/// Random number generator based on `xorshift128+` algorithm by S.Vigna (2015).
/// The reference implementation in C can be found in <https://arxiv.org/abs/1404.0390> (V3).
class Xorshift128p extends RandomBase64 {
  Xorshift128p([int? a, int? b]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (a != null || b != null) {

      if (a==null) {
        throw ArgumentError.notNull('a');
      }
      if (b==null) {
        throw ArgumentError.notNull('b');
      }

      _S0 = a;
      _S1 = b;

      if (a == 0 && b == 0) {
        throw ArgumentError('The seed should not consist of only zeros..');
      }
    } else {
      final now = DateTime.now().microsecondsSinceEpoch;
      // just creating a mess
      _S0 = mess2to64A(now, hashCode);
      _S1 = mess2to64B(now, hashCode);
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

  // @override
  // double nextDouble() {
  //   var x = nextInt64();
  //
  //   // Vigna suggests <https://prng.di.unimi.it/> "аn alternative, multiplication-free
  //   // conversion" of Uint64 to double like that:
  //   //
  //   // static inline double to_double(uint64_t x) {
  //   //   const union { uint64_t i; double d; } u = { .i = UINT64_C(0x3FF) << 52 | x >> 12 };
  //   //   return u.d - 1.0;
  //   // }
  //   //
  //   // IMHO "multiplication-free" is not a choice for languages that do not allow direct access
  //   // to memory areas. But in the case specifically with xorshift128+ we were trying to match
  //   // the results with <https://git.io/JqWCP>.
  //   //
  //   // Madsen uses the following reference code:
  //   //
  //   // const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
  //   // return *((double *) &x_doublefied) - 1.0;
  //   //
  //   // Which is successfully simulated in javascript like this:
  //   //   t2[0] * 2.3283064365386963e-10 + (t2[1] >>> 12) * 2.220446049250313e-16;
  //   // or
  //   //   t2[0] * Math.pow(2, -32) + (t2[1] >>> 12) * Math.pow(2, -52);
  //   //
  //   // We started with the fact that this is an alternative method without multiplication.
  //   // Now we have two multiplications and a few extra operations.
  //
  //   final resL = x & 0xffffffff;
  //   //int resU = x.unsignedRightShift(32);
  //   final resU = x >= 0 ? x >> 32 : ((x & INT64_MAX_POSITIVE) >> 32) | (1 << (63 - 32));
  //
  //   return resU * 2.3283064365386963e-10 + (resL >> 12) * 2.220446049250313e-16;
  // }

  static final int _deterministicSeedA = int.parse('0x0ad1ea48a354036c');
  static final int _deterministicSeedB = int.parse('0x67c3c3204c3ae1f3');

  static Xorshift128p expected() {
    return Xorshift128p(_deterministicSeedA, _deterministicSeedB);
  }
}

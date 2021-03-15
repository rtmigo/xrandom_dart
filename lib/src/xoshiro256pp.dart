// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xrandom/src/seeding.dart';

import '00_ints.dart';
import 'package:xrandom/src/10_random_base.dart';

/// Random number generator based on `xoshiro256++ 1.0` algorithm by D. Blackman and
/// S. Vigna (2019). The reference implementation in C can be found in
/// <https://prng.di.unimi.it/xoshiro256plusplus.c>.
class Xoshiro256pp extends RandomBase64 {
  Xoshiro256pp([int? a, int? b, int? c, int? d]) {

    if (a != null || b != null || c != null || d != null) {

      if (a == 0 && b == 0 && c == 0 && d == 0) {
        throw ArgumentError('The seed should not consist of only zeros.');
      }

      _S0 = a!;
      _S1 = b!;
      _S2 = c!;
      _S3 = d!;


    } else {
      final now = DateTime.now().microsecondsSinceEpoch;
      _S0 = mess2to64A(now, hashCode) & 0xFFFFFFFF;
      _S1 = mess2to64B(now, hashCode) & 0xFFFFFFFF;
      _S2 = mess2to64C(now, hashCode) & 0xFFFFFFFF;
      _S3 = mess2to64D(now, hashCode) & 0xFFFFFFFF;
    }
  }

  late int _S0, _S1, _S2, _S3;

  //Uint64

  // static rotl(int x, int k) {
  //   //return (x << k) | (x >> (32 - k));
  //   return ((x << k)& 0xFFFFFFFF) |
  //
  //   ( // same as (x) >>> (32-k)
  //       (x) >> (32-k)) & ~(-1 << (64 - (32-k))  )
  //
  //   //x.unsignedRightShift(32-k)
  //
  //   //(x >> (32 - k)) & ~(-1 << (64 - (32 - k)))
  //   //(x >> (32 - k))
  //
  //   ;
  // }

  @override
  int nextInt64() {
    // https://prng.di.unimi.it/xoshiro256plusplus.c

    // rotl(s[0] + s[3], 23) + s[0]
    final result = (((_S0+_S3)<<23)|(((_S0+_S3)>>(64-23))&~((-1<<(64-(64-23)))))) + _S0;

    final t = _S1 << 17;

    _S2 ^= _S0;
    _S3 ^= _S1;
    _S1 ^= _S2;
    _S0 ^= _S3;

    _S2 ^= t;

    //_S3 = rotl(_S3, 45);
    _S3 = ((_S3<<45)|((_S3>>(64-45))&~((-1<<(64-(64-45))))));

    return result;
  }

  // static Xoshiro128pp deterministic() {
  //   return Xoshiro128pp(1081037251, 1975530394, 2959134556, 1579461830);
  // }
}

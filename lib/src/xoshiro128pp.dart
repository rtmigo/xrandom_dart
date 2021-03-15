// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xrandom/src/seeding.dart';

import '00_ints.dart';
import 'package:xrandom/src/10_random_base.dart';

/// Random number generator based on `xoshiro128++ 1.0` algorithm by D. Blackman and
/// S. Vigna (2019). The reference implementation in C can be found in
/// <https://prng.di.unimi.it/xoshiro128plusplus.c>.
class Xoshiro128pp extends RandomBase32 {
  Xoshiro128pp([int? a, int? b, int? c, int? d]) {
    if (a != null || b != null || c != null || d != null) {
      RangeError.checkValueInInterval(a!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(b!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(c!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(d!, 0, UINT32_MAX);

      if (a == 0 && b == 0 && c == 0 && d == 0)
        throw ArgumentError("The seed should not consist of only zeros..");

      _S0 = a;
      _S1 = b;
      _S2 = c;
      _S3 = d;
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

  int nextInt32() {
    // https://prng.di.unimi.it/xoshiro128plusplus.c

    final rotlX1 = (_S0 + _S3) & 0xFFFFFFFF;
    //const rotlK1 = 7;
    final rotl1 = ((rotlX1 << 7) & 0xFFFFFFFF) |
        ( // same as (x) >>> (32-k)
                (rotlX1) >> (32 - 7)) &
            ~(-1 << (64 - (32 - 7)));

    final result = rotl1 + _S0; // #rotl((_S0+_S3)&0xFFFFFFFF, 7) + _S0;

    final t = (_S1 << 9) & 0xFFFFFFFF;

    _S2 ^= _S0;
    _S3 ^= _S1;
    _S1 ^= _S2;
    _S0 ^= _S3;

    _S2 ^= t;

    // ROTL again

    _S3 = ((_S3 << 11) & 0xFFFFFFFF) |
        ( // same as (x) >>> (32-k)
                (_S3) >> (32 - 11)) &
            ~(-1 << (64 - (32 - 11)));

    return result & 0xFFFFFFFF;
  }

  static Xoshiro128pp expected() {
    return Xoshiro128pp(0x17f235fb, 0x53985f9c, 0xbc8d40f6, 0xc7b9d576);
  }
}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/20_seeding.dart';
import 'package:xrandom/src/21_base32.dart';

import '00_ints.dart';

/// Random number generator based on **xoshiro128++ 1.0** algorithm by D. Blackman and
/// S. Vigna (2019). The reference implementation in C can be found in
/// <https://prng.di.unimi.it/xoshiro128plusplus.c>.
class Xoshiro128pp extends RandomBase32 {
  Xoshiro128pp([int? a, int? b, int? c, int? d]) {
    if (a != null || b != null || c != null || d != null) {
      RangeError.checkValueInInterval(a!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(b!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(c!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(d!, 0, UINT32_MAX);

      if (a == 0 && b == 0 && c == 0 && d == 0) {
        throw ArgumentError('The seed should not consist of only zeros.');
      }

      _S0 = a;
      _S1 = b;
      _S2 = c;
      _S3 = d;
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      _S0 = mess2to64A(now, hashCode) & 0xFFFFFFFF;
      _S1 = mess2to64B(now, hashCode) & 0xFFFFFFFF;
      _S2 = mess2to64C(now, hashCode) & 0xFFFFFFFF;
      _S3 = mess2to64D(now, hashCode) & 0xFFFFFFFF;
    }
  }

  late int _S0, _S1, _S2, _S3;

  @override
  int nextRaw32() {
    // https://prng.di.unimi.it/xoshiro128plusplus.c

    final rotlX1 = (_S0 + _S3) & 0xFFFFFFFF;
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

  // 3d1dc8a9 35bd9d36 387f1182 4eb8afb6
  // 8e446f3a 3918f5f9 5c0a0b89 4a3a19c3
  // 97382e38 f6a908dd abec010a 86797d7d
  // 1f2f7252 ef22f9ba 342cf1c2 7152f3fe

  // static const defaultSeedA = 0x8e446f3a;
  // static const defaultSeedB = 0x3918f5f9;
  // static const defaultSeedC = 0x5c0a0b89;
  // static const defaultSeedD = 0x4a3a19c3;

  static const defaultSeedA = 0x543f8723;
  static const defaultSeedB = 0xb887dcb9;
  static const defaultSeedC = 0xe97537a6;
  static const defaultSeedD = 0x39e0f840;

  static Xoshiro128pp expected() {
    return Xoshiro128pp(defaultSeedA, defaultSeedB, defaultSeedC, defaultSeedD);
  }
}

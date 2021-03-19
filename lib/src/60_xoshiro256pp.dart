// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/50_splitmix64.dart';

import '21_base64.dart';

/// Random number generator based on **xoshiro256++ 1.0** algorithm by D. Blackman and
/// S. Vigna (2019). The reference implementation in C can be found in
/// <https://prng.di.unimi.it/xoshiro256plusplus.c>.
class Xoshiro256pp extends RandomBase64 {
  Xoshiro256pp([int? seed64a, int? seed64b, int? seed64c, int? seed64d]) {
    if (seed64a != null || seed64b != null || seed64c != null || seed64d != null) {
      _S0 = seed64a!;
      _S1 = seed64b!;
      _S2 = seed64c!;
      _S3 = seed64d!;
      if ((_S0|_S1|_S2|_S3) == 0) {
        throw ArgumentError('The seed should not consist of only zeros.');
      }
    } else {
      _S0 = Splitmix64.instance.nextRaw64();
      _S1 = Splitmix64.instance.nextRaw64();
      _S2 = Splitmix64.instance.nextRaw64();
      _S3 = Splitmix64.instance.nextRaw64();
    }
  }

  late int _S0, _S1, _S2, _S3;

  @override
  int nextRaw64() {
    // https://prng.di.unimi.it/xoshiro256plusplus.c

    final result =
        (((_S0 + _S3) << 23) | (((_S0 + _S3) >> (64 - 23)) & ~((-1 << (64 - (64 - 23)))))) + _S0;

    final t = _S1 << 17;

    _S2 ^= _S0;
    _S3 ^= _S1;
    _S1 ^= _S2;
    _S0 ^= _S3;

    _S2 ^= t;

    _S3 = ((_S3 << 45) | ((_S3 >> (64 - 45)) & ~((-1 << (64 - (64 - 45))))));

    return result;
  }

  static Xoshiro256pp expected() {
    return Xoshiro256pp(
        defaultSeedA, defaultSeedB, defaultSeedC, defaultSeedD);
  }

  static final defaultSeedA = int.parse('0x621b97ff9b08ce44');
  static final defaultSeedB = int.parse('0x92974ae633d5ee97');
  static final defaultSeedC = int.parse('0x9c7e491e8f081368');
  static final defaultSeedD = int.parse('0xf7d3b43bed078fa3');
}

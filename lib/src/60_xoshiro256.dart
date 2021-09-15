// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/50_splitmix64.dart';

import '21_base64.dart';

/// Base class for Xoshiro256++ and Xoshiro256**
abstract class Xoshiro256 extends RandomBase64 {
  Xoshiro256([int? seed64a, int? seed64b, int? seed64c, int? seed64d]) {
    if (seed64a != null || seed64b != null || seed64c != null || seed64d != null) {
      _S0 = seed64a!;
      _S1 = seed64b!;
      _S2 = seed64c!;
      _S3 = seed64d!;
      if ((_S0 | _S1 | _S2 | _S3) == 0) {
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

  int _next_result_init();

  @override
  int nextRaw64() {
    // the only difference between 256PP and 256SS is in the next line.
    // TODO Maybe, instead of calling a function, copy-paste the code inline for speed?
    final result = _next_result_init();

    final t = _S1 << 17;

    _S2 ^= _S0;
    _S3 ^= _S1;
    _S1 ^= _S2;
    _S0 ^= _S3;

    _S2 ^= t;

    _S3 = ((_S3 << 45) | ((_S3 >> (64 - 45)) & ~((-1 << (64 - (64 - 45))))));

    return result;
  }

  static final defaultSeedA = int.parse('0x621b97ff9b08ce44');
  static final defaultSeedB = int.parse('0x92974ae633d5ee97');
  static final defaultSeedC = int.parse('0x9c7e491e8f081368');
  static final defaultSeedD = int.parse('0xf7d3b43bed078fa3');
}

/// Random number generator based on **xoshiro256++ 1.0** algorithm by D. Blackman and S. Vigna.
///
/// [reference](https://prng.di.unimi.it/xoshiro256plusplus.c)
class Xoshiro256pp extends Xoshiro256 {
  Xoshiro256pp([int? seed64a, int? seed64b, int? seed64c, int? seed64d])
      : super(seed64a, seed64b, seed64c, seed64d);

  @override
  int _next_result_init() {
    return (((_S0 + _S3) << 23) | (((_S0 + _S3) >> (64 - 23)) & ~((-1 << (64 - (64 - 23)))))) + _S0;
  }

  static Xoshiro256pp seeded() {
    return Xoshiro256pp(Xoshiro256.defaultSeedA, Xoshiro256.defaultSeedB, Xoshiro256.defaultSeedC,
        Xoshiro256.defaultSeedD);
  }
}

/// Random number generator based on **xoshiro256\*\* 1.0** algorithm by D. Blackman and S. Vigna.
///
/// [reference](https://xoshiro.di.unimi.it/xoshiro256starstar.c)
class Xoshiro256ss extends Xoshiro256 {
  Xoshiro256ss([int? seed64a, int? seed64b, int? seed64c, int? seed64d])
      : super(seed64a, seed64b, seed64c, seed64d);

  @override
  int _next_result_init() {
    return (((_S1 * 5) << 7) | (((_S1 * 5) >> (64 - 7)) & ~((-1 << (64 - (64 - 7)))))) * 9;
  }

  static Xoshiro256ss seeded() {
    return Xoshiro256ss(Xoshiro256.defaultSeedA, Xoshiro256.defaultSeedB, Xoshiro256.defaultSeedC,
        Xoshiro256.defaultSeedD);
  }
}

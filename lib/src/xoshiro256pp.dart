// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/10_random_base.dart';
import 'package:xrandom/src/splitmix64.dart';

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
      _S0 = Splitmix64.instance.nextInt64();
      _S1 = Splitmix64.instance.nextInt64();
      _S2 = Splitmix64.instance.nextInt64();
      _S3 = Splitmix64.instance.nextInt64();
    }
  }

  late int _S0, _S1, _S2, _S3;

  @override
  int nextInt64() {
    // https://prng.di.unimi.it/xoshiro256plusplus.c

    // rotl(s[0] + s[3], 23) + s[0]
    final result = (((_S0 + _S3) << 23) |
            (((_S0 + _S3) >> (64 - 23)) & ~((-1 << (64 - (64 - 23)))))) +
        _S0;

    final t = _S1 << 17;

    _S2 ^= _S0;
    _S3 ^= _S1;
    _S1 ^= _S2;
    _S0 ^= _S3;

    _S2 ^= t;

    //_S3 = rotl(_S3, 45);
    _S3 = ((_S3 << 45) | ((_S3 >> (64 - 45)) & ~((-1 << (64 - (64 - 45))))));

    return result;
  }

  static Xoshiro256pp expected() {
    return Xoshiro256pp(
        _defaultSeedA, _defaultSeedB, _defaultSeedC, _defaultSeedD);
  }

  static final _defaultSeedA = int.parse('0x621b97ff9b08ce44');
  static final _defaultSeedB = int.parse('0x92974ae633d5ee97');
  static final _defaultSeedC = int.parse('0x9c7e491e8f081368');
  static final _defaultSeedD = int.parse('0xf7d3b43bed078fa3');
}

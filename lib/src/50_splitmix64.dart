// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import '00_errors.dart';
import '00_ints.dart';
import '21_base64.dart';

/// Random number generator based on **splitmix64** algorithm by S. Vigna (2015).
/// The reference implementation in C can be found in
/// <https://prng.di.unimi.it/splitmix64.c>.
class Splitmix64 extends RandomBase64 {
  static final _defaultSeed = int.parse('0x76a5c5b65ce8677c');

  Splitmix64([seed]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (seed != null) {
      _x = seed;
    } else {
      _x = DateTime.now().microsecondsSinceEpoch ^ this.hashCode;
    }
  }

  late int _x;

  static final _c9E3 = int.parse('0x9e3779b97f4a7c15');
  static final _cBF5 = int.parse('0xbf58476d1ce4e5b9');
  static final _c94D = int.parse('0x94d049bb133111eb');

  @override
  int nextRaw64() {
    // based on
    // https://prng.di.unimi.it/splitmix64.c
    // (c) 2015 by Sebastiano Vigna (CC-0)

    int z = (_x += _c9E3);
    // C99: z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
    z = (z ^ (z >> 30) & ~(-1 << (64 - 30))) * _cBF5;
    // C99: z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
    z = (z ^ (z >> 27) & ~(-1 << (64 - 27))) * _c94D;
    // C99: return z ^ (z >> 31);
    return z ^ (z >> 31) & ~(-1 << (64 - 31));
  }

  static Splitmix64 expected() {
    return Splitmix64(_defaultSeed);
  }

  static final Splitmix64 instance = Splitmix64();
}

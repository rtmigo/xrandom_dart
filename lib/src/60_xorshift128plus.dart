// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/50_splitmix64.dart';

import '00_errors.dart';
import '00_ints.dart';
import '21_base64.dart';

enum Xorshift128pConstants { c23_18_5 }

/// Random number generator based on **xorshift128+** algorithm by S. Vigna.
///
/// -------
///
/// There were at least two known versions of this algorithm.
///
/// With constants 23, 17, 26:
/// - in [paper](https://arxiv.org/pdf/1404.0390v1.pdf) - Apr 2014
/// - in [JavaScript V8 engine](https://git.io/Jqpma)
/// - on [Wikipedia](https://en.wikipedia.org/wiki/Xorshift>) - 2021
///
/// With constants 23, 18, 5:
/// - in [paper](https://arxiv.org/pdf/1404.0390v2.pdf) - Dec 2015
/// - in [paper](https://arxiv.org/pdf/1404.0390v3.pdf) - May 2016
/// - in [JavaScript xorshift library](https://git.io/JqWCP)
///
/// "the most recent set of constants according to the author of the algorithm are:
/// 23, 18, and 5. Those are theoretically better than the initial set of numbers"
/// [>>](https://stackoverflow.com/a/34432126)
///
/// This class uses the most recent constants: 23, 18, 5.
class Xorshift128p extends RandomBase64 {
  Xorshift128p([int? seedA, int? seedB]) {
    if (!INT64_SUPPORTED) {
      throw Unsupported64Error();
    }
    if (seedA != null || seedB != null) {
      if (seedA == null) {
        throw ArgumentError.notNull('a');
      }
      if (seedB == null) {
        throw ArgumentError.notNull('b');
      }

      _S0 = seedA;
      _S1 = seedB;

      if (seedA == 0 && seedB == 0) {
        throw ArgumentError('The seed should not consist of only zeros..');
      }
    } else {
      // just creating a mess
      _S0 = Splitmix64.instance.nextRaw64();
      _S1 = Splitmix64.instance.nextRaw64();
    }
  }

  late int _S0, _S1;

  @override
  int nextRaw64() {
    var s1 = _S0;
    final s0 = _S1;
    final result = s0 + s1;
    _S0 = s0;
    s1 ^= s1 << 23; // a

    // C: _S1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
    // DartV1: _S1 = s1 ^ s0 ^ (s1.unsignedRightShift(18)) ^ (s0.unsignedRightShift(5)); // b, c

    _S1 = s1 ^
        s0 ^
        ( // rewritten: s1.unsignedRightShift(18)
            (s1 >> 18) & ~(-1 << (64 - 18))) ^
        ( // rewritten: s1 s0.unsignedRightShift(5)
            (s0 >> 5) & ~(-1 << (64 - 5))); // b, c

    return result;
  }

  static final int _deterministicSeedA = int.parse('0x0ad1ea48a354036c');
  static final int _deterministicSeedB = int.parse('0x67c3c3204c3ae1f3');

  static Xorshift128p seeded() {
    return Xorshift128p(_deterministicSeedA, _deterministicSeedB);
  }
}

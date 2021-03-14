// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import 'dart:math';

import 'errors.dart';
import 'ints.dart';
import 'package:xorshift/src/unirandom.dart';

class Xorshift64 extends UniRandom64 {
  static final _defaultSeed = BigInt.parse("0x76a5c5b65ce8677c").toInt();

  Xorshift64([seed]) {
    if (!INT64_SUPPORTED) throw Unsupported64Error();

    if (seed != null) {
      if (seed == 0) throw RangeError("The seed must be greater than 0.");
      this._state = seed;
    } else
      this._state = DateTime.now().microsecondsSinceEpoch;
  }

  late int _state;

  int next64() {
    // algorithm from p.4 of "Xorshift RNGs"
    // by George Marsaglia, 2003
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift

    int x = _state;
    x ^= x << 13;
    x ^= x.unsignedRightShift(7);
    x ^= x << 17;
    return _state = x;
  }

  static Xorshift64 deterministic() {
    return Xorshift64(_defaultSeed);
  }
}

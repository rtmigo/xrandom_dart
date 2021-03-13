// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'ints.dart';
import 'package:xorshift/src/unirandom.dart';

class Xorshift64 extends UniRandom64
{
  Xorshift64([seed])
  {
    if (seed!=null) {
      if (seed==0)
        throw RangeError("The seed must be greater than 0.");
      this._state = seed;
    }
    else
      this._state = DateTime.now().microsecondsSinceEpoch;

  }
  late int _state;

  int next() {

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

  static Xorshift64 deterministic()
  {
    return Xorshift64(0x76a5c5b65ce8677c);
  }
}
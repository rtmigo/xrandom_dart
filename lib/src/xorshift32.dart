// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'package:xorshift/src/unirandom.dart';

class Xorshift32 extends UniRandom32
{
  Xorshift32([seed])
  {
    if (seed!=null) {
      RangeError.checkValueInInterval(seed, 1, 0xFFFFFFFF);
      this._state = seed;
    }
    else
      this._state = DateTime.now().millisecondsSinceEpoch & 0xFFFFFFFF;
  }
  late int _state;

  static Xorshift32 deterministic() => Xorshift32(314159265);

  int next32() {

    // algorithm from p.4 of "Xorshift RNGs" 
    // by George Marsaglia, 2003 
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift

    int x = _state;

    x ^= (x << 13);
    x &= 0xFFFFFFFF; // added
    x ^= (x >> 17);
    x ^= (x << 5);
    x &= 0xFFFFFFFF; // added

    return _state = x;
  }
}
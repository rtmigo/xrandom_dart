// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'ints.dart';
import 'package:xorhift/src/unirandom.dart';

class Xorshift128Random extends UniRandom32
{
  Xorshift128Random(this._a, this._b, this._c, this._d)
  {
    RangeError.checkValueInInterval(this._a, 0, MAX_UINT32);
    RangeError.checkValueInInterval(this._b, 0, MAX_UINT32);
    RangeError.checkValueInInterval(this._c, 0, MAX_UINT32);
    RangeError.checkValueInInterval(this._d, 0, MAX_UINT32);
  }
  int _a, _b, _c, _d;

  int next() {

    // algorithm from p.5 of "Xorshift RNGs"
    // by George Marsaglia, 2003
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift

    int t = _d;
    final s = _a;
    _d = _c;
    _c = _b;
    _b = s;

    t ^= t << 11;
    t &= 0xFFFFFFFF;

    t ^= t.unsignedRightShift(8); //t ^= t >> 8;
    //return _a = t ^ s ^ (s >> 19);

    _a = t ^ s ^ (s >> 19);
    _a &= 0xFFFFFFFF;

    return _a; //return _a = t ^ s ^ (s >> 19);
  }



  static Xorshift128Random deterministic()
  {
    return Xorshift128Random(1081037251, 1975530394, 2959134556, 1579461830);
  }
}
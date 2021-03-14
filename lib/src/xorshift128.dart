// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'ints.dart';
import 'package:xorshift/src/unirandom.dart';

class Xorshift128 extends UniRandom32
{
  Xorshift128([int? a, int? b, int? c, int? d])
  {
    if (a!=null || b!=null || c!=null || d!=null) {

      RangeError.checkValueInInterval(a!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(b!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(c!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(d!, 0, UINT32_MAX);

      // todo check they cannot be null the same time?

      _a = a;
      _b = b;
      _c = c;
      _d = d;
    }
    else {
      final now = DateTime.now().microsecondsSinceEpoch;
      // just creating a mess
      _a = now & 0xFFFFFFFF;
      _b = ((now>>4) ^ 0xa925b6aa) & 0xFFFFFFFF;
      _c = ((now>>8) ^ 0xcf044101) & 0xFFFFFFFF;
      _d = ((now>>11) ^ 0x716ac5dd) & 0xFFFFFFFF;
    }
  }
  late int _a, _b, _c, _d;

  int next32() {

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

    //t ^= t >> 8;
    //t ^= t.unsignedRightShift(8); //t ^= t >> 8;
    t^=t >= 0 ? t >> 8 : ((t & INT64_MAX_POSITIVE) >> 8) | (1 << (63 - 8));


    //return _a = t ^ s ^ (s >> 19);

    _a = t ^ s ^ (s >> 19);
    _a &= 0xFFFFFFFF;

    return _a; //return _a = t ^ s ^ (s >> 19);
  }

  static Xorshift128 deterministic()
  {
    return Xorshift128(1081037251, 1975530394, 2959134556, 1579461830);
  }
}
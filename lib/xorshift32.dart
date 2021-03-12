import 'dart:math';

import 'package:xorhift/unirandom.dart';

class XorShift32 extends UniRandom32
{
  XorShift32(this._state);
  int _state;

  int next() {

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
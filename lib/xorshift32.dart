import 'dart:math';

import 'package:xorhift/unirandom.dart';

class Xorshift32Random extends UniRandom32
{
  Xorshift32Random(this._state);
  int _state;

  static Xorshift32Random deterministic() => Xorshift32Random(314159265);

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
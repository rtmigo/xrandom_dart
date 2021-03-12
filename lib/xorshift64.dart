import 'dart:math';

import 'ints.dart';
import 'package:xorhift/unirandom.dart';

class Xorshift64Random extends UniRandom64
{
  Xorshift64Random(this._state);
  int _state;

  int next() {

    // algorithm from p.4 of "Xorshift RNGs"
    // by George Marsaglia, 2003
    // https://www.jstatsoft.org/article/view/v008i14
    //
    // rewritten for Dart from snippet
    // found at https://en.wikipedia.org/wiki/Xorshift


    int x = _state;
    x ^= x << 13;
    x ^= x.signedRightShift(7);
    x ^= x << 17;
    return _state = x;
  }

  static Xorshift64Random deterministic()
  {
    return Xorshift64Random(0x76a5c5b65ce8677c);
  }
}
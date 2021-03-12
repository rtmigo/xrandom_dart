import 'dart:math';

import 'ints.dart';
import 'package:xorhift/unirandom.dart';

class Xorshift128PlusRandom extends UniRandom64
{
  Xorshift128PlusRandom(this._S0, this._S1)
  {
    // this._S0 = a;
    // this._S1 = b;
  }
  int _S0, _S1;

  int next() {

    // algorithm from "Further scramblings of Marsaglia’s xorshift generators"
    // by Sebastiano Vigna
    //
    // https://arxiv.org/abs/1404.0390 [v2] Mon, 14 Dec 2015 - page 6
    // https://arxiv.org/abs/1404.0390 [v3] Mon, 23 May 2016 - page 6

    int s1 = _S0;
    final int s0 = _S1;
    final int result = s0 + s1;
    _S0 = s0;
    s1 ^= s1 << 23; // a
    //_S1 = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
    _S1 = s1 ^ s0 ^ (s1.signedRightShift(18)) ^ (s0.signedRightShift(5)); // b, c
    return result;

  }

  // static Xorshift128Random deterministic()
  // {
  //   return Xorshift128Random(1081037251, 1975530394, 2959134556, 1579461830);
  // }
}
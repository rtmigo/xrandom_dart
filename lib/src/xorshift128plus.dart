// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'ints.dart';
import 'package:xorhift/src/unirandom.dart';

class Xorshift128Plus extends UniRandom64
{
  Xorshift128Plus(this._S0, this._S1)
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
    _S1 = s1 ^ s0 ^ (s1.unsignedRightShift(18)) ^ (s0.unsignedRightShift(5)); // b, c
    return result;

  }

  @override
  double nextDouble() {
    int x = this.next();

    // in C, this is implemented by casting the memory area to the double type.
    // This is not an option here

    // const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
    // return *((double *) &x_doublefied) - 1.0;

    // so we just reimplement it like here
    // https://github.com/AndreasMadsen/xorshift/blob/master/xorshift.js

    int resL = x&0xffffffff;
    int resU = x.unsignedRightShift(32); // todo replace by inline

    return resU*2.3283064365386963e-10 + (resL>>12)*2.220446049250313e-16;
  }

  static Xorshift128Plus deterministic()
  {
    return Xorshift128Plus(8378522730901710845, 1653112583875186020);
  }
}
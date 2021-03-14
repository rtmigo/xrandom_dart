// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:math';

import 'ints.dart';
import 'package:xorshift/src/unirandom.dart';

// https://prng.di.unimi.it/xoshiro128plusplus.c

class Xoshiro128pp extends UniRandom32
{
  Xoshiro128pp([int? a, int? b, int? c, int? d])
  {
    if (a!=null || b!=null || c!=null || d!=null) {

      RangeError.checkValueInInterval(a!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(b!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(c!, 0, UINT32_MAX);
      RangeError.checkValueInInterval(d!, 0, UINT32_MAX);

      // todo check they cannot be null the same time?

      _S0 = a;
      _S1 = b;
      _S2 = c;
      _S3 = d;
    }
    else {
      final now = DateTime.now().microsecondsSinceEpoch;
      // just creating a mess
      _S0 = now & 0xFFFFFFFF;
      _S1 = ((now>>4) ^ 0xa925b6aa) & 0xFFFFFFFF;
      _S2 = ((now>>8) ^ 0xcf044101) & 0xFFFFFFFF;
      _S3 = ((now>>11) ^ 0x716ac5dd) & 0xFFFFFFFF;
    }
  }
  late int _S0, _S1, _S2, _S3;

  static rotl(int x, int k) {
    //return (x << k) | (x >> (32 - k));
    return ((x << k)& 0xFFFFFFFF) |

    ( // same as (x) >>> (32-k)
        (x) >> (32-k)) & ~(-1 << (64 - (32-k))  )

    //x.unsignedRightShift(32-k)

    //(x >> (32 - k)) & ~(-1 << (64 - (32 - k)))
    //(x >> (32 - k))

    ;
  }



  int nextInt32() {

    // https://prng.di.unimi.it/xoshiro128plusplus.c

    final rotlX1 = (_S0+_S3)&0xFFFFFFFF;
    final rotlK1 = 7;
    final rotl1 = ((rotlX1 << rotlK1)& 0xFFFFFFFF) |

    ( // same as (x) >>> (32-k)
        (rotlX1) >> (32-rotlK1)) & ~(-1 << (64 - (32-rotlK1))  );

    final int result = rotl1 + _S0; // #rotl((_S0+_S3)&0xFFFFFFFF, 7) + _S0;

    final int t = (_S1 << 9)& 0xFFFFFFFF;

    _S2 ^= _S0;// & 0xFFFFFFFF;
    _S3 ^= _S1;// & 0xFFFFFFFF;
    _S1 ^= _S2;// & 0xFFFFFFFF;
    _S0 ^= _S3;// & 0xFFFFFFFF;

    _S2 ^= t;// & 0xFFFFFFFF;

    // ROTL again

    _S3 = ((_S3 << 11)& 0xFFFFFFFF) |

    ( // same as (x) >>> (32-k)
        (_S3) >> (32-11)) & ~(-1 << (64 - (32-11))  );


    //_S3 = rotl(_S3, 11);

    return result & 0xFFFFFFFF;

  }

  static Xoshiro128pp deterministic()
  {
    return Xoshiro128pp(1081037251, 1975530394, 2959134556, 1579461830);
  }
}
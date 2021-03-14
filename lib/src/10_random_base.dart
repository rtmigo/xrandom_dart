// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import 'dart:math';
import '00_ints.dart';

// /// Scales an integer from range `(1, MAX_UINT32]` to `[0.0, 1.0)` arithmetically.
// double scaleUint32toDouble(int x)
// {
//   // kept here for reference. Not used for now
//   if (x > 0xFFFFFFFF || x <= 0) {
//     throw RangeError.value(x);
//   }
//   return (x - 1) / UINT32_MAX;
// }

abstract class RandomBase32 implements Random {

  // https://git.io/JqCbB

  static const _POW2_32 = 1 << 32;

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 1 to 0xFFFFFFFF, both inclusive.
  ///
  /// For 32-bit algorithms it is the raw output of the generator.
  int nextInt32();

  @override
  int nextInt(int max) {
    // slightly modified _Random.nextInt() from dart:math (https://git.io/JqCbB)

    // todo loosen this restriction and test possible ranges

    const limit = 0x3FFFFFFF;
    if ((max <= 0) || ((max > limit) && (max > _POW2_32))) {
      throw RangeError.range(max, 1, _POW2_32, 'max', 'Must be positive and <= 2^32');
    }

    if ((max & -max) == max) {
      // fast case for powers of two
      // like in dart:math https://git.io/JqCbB
      final rnd32 = this.nextInt32();
      assert(0<=rnd32 && rnd32<=UINT32_MAX);
      final result = rnd32 & (max - 1);
      assert(0<=result);
      assert(result<max);
    }

    final rnd32 = nextInt32();
    assert(0<=rnd32 && rnd32<=UINT32_MAX);

    final result = rnd32 % max;

    assert(0<=result && result<max);

    return result;
  }

  /// Generates a non-negative random floating point value uniformly distributed
  /// in the range from 0.0, inclusive, to 1.0, exclusive.
  ///
  /// This method works twice as fast as [nextDouble] due to loss of precision.
  /// The result is mapped from a single unsigned 32-bit non-zero integer to [double].
  /// Therefore, the variability is limited by the number of possible values
  /// of such integer: 2^32-1 (= 4 294 967 295).
  double nextFloat() {
    const FACTOR = 1/UINT32_MAX;
    final rnd32 = nextInt32();
    assert(0.0<rnd32 && rnd32 <= UINT32_MAX);
    final double one = (rnd32-1)*FACTOR;
    assert(0.0<=one && one<1.0);
    return one;
  }


  @override
  double nextDouble() {

    return nextInt32()*2.3283064365386963e-10 + (nextInt32()>>12)*2.220446049250313e-16;

    // This method generates results that are similar to:
    // http://rcs.bu.edu/examples/random_numbers/xoroshiro128_plus/C/xoroshiro128_plus.c
    //
    // double next_double(uint64_t seed[]) {
    //    const union { uint64_t i; double d; }
    //    u = { .i = UINT64_C(0x3FF) << 52 | next(seed) >> 12 };
    //    return u.d - 1.0;
    // }
    //
    // A JavaScript snippet for the same results is found here (https://git.io/JqWCP).
    // The similarity of results is also tested there
    //
    // ...
    //
    // dart:math (https://git.io/JqCbB) converts two 32-bit integers to double like that:
    //    static const _POW2_53_D = 1.0 * (1 << 53);
    //    static const _POW2_27_D = 1.0 * (1 << 27);
    //    return ((nextInt(1<<26)*_POW2_27_D) + nextInt(1<<27))/_POW2_53_D;
    // but their code fails on JS (2021-03) for reasons beyond my comprehension.
    // And it's also a way more inefficient: the nextInt itself a way slower than next32
  }

  @override
  bool nextBool() {

    // in dart:math it is return nextInt(2) == 0;
    // which is an equivalent of
    //   if ((2&-2)==2) return next()&(2-1);

    // benchmarks 2021-03 with Xorshift32 (on Dell Seashell):
    //    Random      (from dart:math)            2424
    //    XorShift32  return nextInt(2)==0        2136
    //    XorShift32  this.next() % 2 == 0        1903
    //    XorShift32  this.next() >= 0x80000000   1821

    if (_boolCache_prevIdx==_MAX_BIT_INDEX) {
      _boolCache = nextInt32();
      _boolCache_prevIdx = 0;
      return _boolCache&1 == 1;
    } else {
      assert(_boolCache_prevIdx<_MAX_BIT_INDEX);
      _boolCache_prevIdx++;
      final result = (_boolCache & (1<<_boolCache_prevIdx)) != 0;
      return result;
    }
  }

  static const _MAX_BIT_INDEX = 32-1;
  int _boolCache = 0;
  int _boolCache_prevIdx = _MAX_BIT_INDEX;
}

abstract class RandomBase64 extends RandomBase32 {

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 1 to 2^64-1, both inclusive.
  ///
  /// It is the raw output of the generator.
  int nextInt64();

  /// Generates a non-negative random integer uniformly distributed in the range
  /// from 1 to 0xFFFFFFFF, both inclusive.
  ///
  /// For 64-bit algorithms it sequentially returns the lower and higher bytes
  /// of the raw output of the generator.
  @override
  int nextInt32() {
    
    // we assume that the random generator never returns 0,
    // so 0 means "not initialized".
    
    if (_forNext32==0) {
      _forNext32 = this.nextInt64();
      return _forNext32 & UINT32_MAX; // returning lower 4 bytes
    } else {
      // we have a value: that means, we're already returned
      // the lower 4 bytes of it. Now we'll return the higher 4 bytes

      final x = _forNext32;
      _forNext32 = 0; // on the next call we'll a new random here

      const shift = 32;
      // and here's our favorite unsigned right shift
      return x >= 0
          ? x >> shift
          : ((x & INT64_MAX_POSITIVE) >> shift) | (1 << (63 - shift));
    }
  }

  int _forNext32 = 0;


  @override
  double nextDouble() {

    // we have a 64-bit integer to be converted to a float with only 53 significant bits.

    // Sebastiano Vigna (https://prng.di.unimi.it/):
    // 64-bit unsigned integer x should be converted to a 64-bit double using the expression
    //   (x >> 11) * 0x1.0p-53
    // In Java you can use almost the same expression for a (signed) 64-bit integer:
    //   (x >>> 11) * 0x1.0p-53

    const double Z = 1.110223e-16; // 0x1.0p-53

    //     ( this.nextInt64() >>> 11                       ) * 0x1.0p-53
    return ( (this.nextInt64() >> 11) & ~(-1 << (64 - 11)) ) * Z;
  }


  double _nextDoubleNaive() {
    // todo remove?

    int x = this.nextInt64();

    if (x > INT64_MAX_POSITIVE)
      throw AssertionError("Unexpected 64-bit value generated by .next(): $x");
    else {
      if (x < 0) {
        x&=INT64_MAX_POSITIVE; // unsetting the highest bit
        //x = x.unsetHighestBit64();
      }
    }

    assert(x >= 0);
    assert(x <= INT64_MAX_POSITIVE);

    // scaling x from (0, MAX_POSITIVE_INT64] to [0.0, 1.0).
    return (x - 1) / INT64_MAX_POSITIVE;
  }

  @override
  bool nextBool() {

    // in dart:math it is return nextInt(2) == 0;
    // which is an equivalent of
    //   if ((2&-2)==2) return next()&(2-1);

    // benchmarks 2021-03 with Xorshift32 (on Dell Seashell):
    //    Random      (from dart:math)            2424
    //    XorShift32  return nextInt(2)==0        2136
    //    XorShift32  this.next() % 2 == 0        1903
    //    XorShift32  this.next() >= 0x80000000   1821

    if (_boolCache_prevIdx==_MAX_BIT_INDEX) {

      _boolCache = nextInt64();
      _boolCache_prevIdx = 0;
      return _boolCache&1 == 1;
    } else {
      assert(_boolCache_prevIdx<_MAX_BIT_INDEX);
      _boolCache_prevIdx++;
      final result = (_boolCache & (1<<_boolCache_prevIdx)) != 0;
      return result;
    }
  }

  static const _MAX_BIT_INDEX = 64-1;
  //int _boolCache = 0;
  int _boolCache_prevIdx = _MAX_BIT_INDEX;
}

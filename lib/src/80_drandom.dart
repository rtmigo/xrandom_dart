import '60_xoshiro128pp.dart';

class Drandom extends Xoshiro128pp {
  Drandom()
      : super(Xoshiro128pp.defaultSeedA, Xoshiro128pp.defaultSeedB, Xoshiro128pp.defaultSeedC,
      Xoshiro128pp.defaultSeedD);

  /// Generates a non-negative random integer uniformly distributed in
  /// the range from 0, inclusive, to [max], exclusive.
  ///
  /// To make the distribution uniform, we use the so-called
  /// [Debiased Modulo Once - Java Method](https://git.io/Jm0D7).
  ///
  /// This implementation is slightly faster than the standard one for
  /// all [max] values, except for [max], which are powers of two.
  // @override
  // int nextInt(int max) {
  //   if (max < 1 || max > 0x7FFFFFFF) {
  //     throw RangeError.range(max, 1, 0x7FFFFFFF);
  //   }
  //   int r = nextRaw32();
  //   int m = max - 1;
  //   for (int u = r; u - (r = u % max) + m < 0; u = nextRaw32()) {}
  //   return r;
  // }

}

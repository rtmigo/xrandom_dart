// TODO Replace with type aliases when feature will be available
// https://github.com/dart-lang/language/issues/65

import '60_xorshift32.dart';
import '60_xoshiro128pp.dart';

class Xrandom extends Xorshift32 {
  Xrandom([seed32]) : super(seed32);

  static Xorshift32 expected() => Xrandom(Xorshift32.defaultSeed);
}

class XrandomHq extends Xoshiro128pp {
  XrandomHq._fullSeed(int a32, int b32, int c32, d32) : super(a32, b32, c32, d32);

  XrandomHq._noSeed() : super();

  factory XrandomHq([int? seed]) {
    if (seed == null) {
      return XrandomHq._noSeed();
    }

    RangeError.checkValueInInterval(seed, 1, 0xFFFFFFFF);

    // creating two generators and skipping the first value
    final r1 = Xorshift32(seed ^ 0x17f235fb)..nextRaw32();
    final r2 = Xorshift32(seed ^ 0x53985f9c)..nextRaw32();

    // seeding values from smaller generators to the big one
    return XrandomHq._fullSeed(r1.nextRaw32(), r2.nextRaw32(), r1.nextRaw32(), r2.nextRaw32());
  }

  static XrandomHq expected() => XrandomHq._fullSeed(
    Xoshiro128pp.defaultSeedA,
    Xoshiro128pp.defaultSeedB,
    Xoshiro128pp.defaultSeedC,
    Xoshiro128pp.defaultSeedD);
}

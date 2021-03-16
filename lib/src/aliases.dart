// TODO Replace with type aliases when feature will be available
// https://github.com/dart-lang/language/issues/65

import 'package:xrandom/src/seeding.dart';

import 'splitmix64.dart';
import 'xorshift32.dart';
import 'xoshiro128pp.dart';
import 'xoshiro256pp.dart';

class Xrandom extends Xorshift32 {
  Xrandom([seed32]) : super(seed32);
  static Xorshift32 expected() => Xrandom(Xorshift32.defaultSeed);
}

class XrandomHq extends Xoshiro256pp {

  XrandomHq._fullSeed(int a64, int b64, int c64, d64): super(a64, b64, c64, d64);
  XrandomHq._noSeed(): super();

  factory XrandomHq([int? seed64])
  {
    if (seed64==null) {
      return XrandomHq._noSeed();
    }

    final seeder = Splitmix64(seed64);
    return XrandomHq._fullSeed(
        seeder.nextInt64(), seeder.nextInt64(), seeder.nextInt64(), seeder.nextInt64());
  }

  static XrandomHq expected() => XrandomHq._fullSeed(
    Xoshiro256pp.defaultSeedA,
    Xoshiro256pp.defaultSeedB,
    Xoshiro256pp.defaultSeedC,
    Xoshiro256pp.defaultSeedD,
  );
}

class _Hashmaker {}

class XrandomHqJs extends Xoshiro128pp {

  XrandomHqJs._fullSeed(int a32, int b32, int c32, d32): super(a32, b32, c32, d32);
  XrandomHqJs._noSeed(): super();

  factory XrandomHqJs([int? seed64])
  {
    if (seed64==null) {
      return XrandomHqJs._noSeed();
    }

    final nx = DateTime.now().microsecondsSinceEpoch;
    // todo is there a way to avoid constructing object just for hash?
    final ny = _Hashmaker().hashCode;

    return XrandomHqJs._fullSeed(
        mess2to64A(nx, ny) & 0xFFFFFFFF,
        mess2to64B(nx, ny) & 0xFFFFFFFF,
        mess2to64D(nx, ny) & 0xFFFFFFFF,
        mess2to64C(nx, ny) & 0xFFFFFFFF);
  }

  static XrandomHqJs expected() => XrandomHqJs._fullSeed(
    Xoshiro128pp.defaultSeedA,
    Xoshiro128pp.defaultSeedB,
    Xoshiro128pp.defaultSeedC,
    Xoshiro128pp.defaultSeedD,
  );
}

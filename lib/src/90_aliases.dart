// TODO Replace with type aliases when feature will be available
// https://github.com/dart-lang/language/issues/65

import 'package:xrandom/src/20_seeding.dart';

import '50_splitmix64.dart';
import '60_xorshift32.dart';
import '60_xoshiro128pp.dart';
import '60_xoshiro256pp.dart';

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
        seeder.nextRaw64(), seeder.nextRaw64(), seeder.nextRaw64(), seeder.nextRaw64());
  }

  static XrandomHq expected() => XrandomHq._fullSeed(
    Xoshiro256pp.defaultSeedA,
    Xoshiro256pp.defaultSeedB,
    Xoshiro256pp.defaultSeedC,
    Xoshiro256pp.defaultSeedD,
  );
}

class _Hashmaker {}

class XrandomJs extends Xoshiro128pp {

  XrandomJs._fullSeed(int a32, int b32, int c32, d32): super(a32, b32, c32, d32);
  XrandomJs._noSeed(): super();

  factory XrandomJs([int? seed64])
  {
    if (seed64==null) {
      return XrandomJs._noSeed();
    }

    final nx = DateTime.now().microsecondsSinceEpoch;
    // todo is there a way to avoid constructing object just for hash?
    final ny = _Hashmaker().hashCode;

    return XrandomJs._fullSeed(
        mess2to64A(nx, ny) & 0xFFFFFFFF,
        mess2to64B(nx, ny) & 0xFFFFFFFF,
        mess2to64D(nx, ny) & 0xFFFFFFFF,
        mess2to64C(nx, ny) & 0xFFFFFFFF);
  }

  static XrandomJs expected() => XrandomJs._fullSeed(
    Xoshiro128pp.defaultSeedA,
    Xoshiro128pp.defaultSeedB,
    Xoshiro128pp.defaultSeedC,
    Xoshiro128pp.defaultSeedD,
  );
}

@Deprecated('Renamed to XrandomJs')
class XrandomHqJs extends Xoshiro128pp {

  XrandomHqJs._fullSeed(int a32, int b32, int c32, d32): super(a32, b32, c32, d32);
  XrandomHqJs._noSeed(): super();

  factory XrandomHqJs([int? seed64])
  {
    if (seed64==null) {
      return XrandomHqJs._noSeed();
    }

    final nx = DateTime.now().microsecondsSinceEpoch;
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

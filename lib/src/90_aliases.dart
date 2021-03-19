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

class _Hashmaker {}

class XrandomHq extends Xoshiro128pp {

  XrandomHq._fullSeed(int a32, int b32, int c32, d32): super(a32, b32, c32, d32);
  XrandomHq._noSeed(): super();

  factory XrandomHq([int? seed64])
  {
    if (seed64==null) {
      return XrandomHq._noSeed();
    }

    final nx = DateTime.now().microsecondsSinceEpoch;
    // todo is there a way to avoid constructing object just for hash?
    final ny = _Hashmaker().hashCode;

    return XrandomHq._fullSeed(
        mess2to64A(nx, ny) & 0xFFFFFFFF,
        mess2to64B(nx, ny) & 0xFFFFFFFF,
        mess2to64D(nx, ny) & 0xFFFFFFFF,
        mess2to64C(nx, ny) & 0xFFFFFFFF);
  }

  static XrandomHq expected() => XrandomHq._fullSeed(
    Xoshiro128pp.defaultSeedA,
    Xoshiro128pp.defaultSeedB,
    Xoshiro128pp.defaultSeedC,
    Xoshiro128pp.defaultSeedD,
  );
}

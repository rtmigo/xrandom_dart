// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause

export 'src/10_random_base.dart' show RandomBase32, RandomBase64;
export 'src/xorshift128plus.dart' show Xorshift128p;
export 'src/xorshift128.dart' show Xorshift128;
export 'src/xorshift64.dart' show Xorshift64;
export 'src/xorshift32.dart' show Xorshift32;
export 'src/xoshiro128pp.dart' show Xoshiro128pp;
export 'src/xoshiro256pp.dart' show Xoshiro256pp;
export 'src/splitmix64.dart' show Splitmix64;

import 'src/xorshift32.dart';
import 'src/xorshift128plus.dart';

// TODO Replace with type aliases when feature will be available
// https://github.com/dart-lang/language/issues/65

class Xrandom extends Xorshift32 {
  Xrandom([seed]): super(seed);
  static Xorshift32 expected() => Xorshift32.expected();
}

class Xrandom64 extends Xorshift128p {
  Xrandom64([a,b]): super(a,b);
  static Xorshift128p expected() => Xorshift128p.expected();
}




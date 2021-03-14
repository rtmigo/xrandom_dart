// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import 'src/xorshift32.dart';
export 'src/xorshift128plus.dart' show Xorshift128Plus;
export 'src/xorshift128.dart' show Xorshift128;
export 'src/xorshift64.dart' show Xorshift64;
export 'src/xorshift32.dart' show Xorshift32;
export 'src/xoshiro128pp.dart' show Xoshiro128pp;
export 'src/unirandom.dart' show UniRandom32, UniRandom64;

class Xorshift extends Xorshift32 {}


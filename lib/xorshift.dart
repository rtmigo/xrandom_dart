// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause
// https://github.com/rtmigo/xorshift

import 'src/xorshift128plus.dart';
export 'src/xorshift128plus.dart' show Xorshift128Plus;
export 'src/xorshift128.dart' show Xorshift128;
export 'src/xorshift64.dart' show Xorshift64;
export 'src/xorshift32.dart' show Xorshift32;

mixin Xorshift on Xorshift128Plus {}

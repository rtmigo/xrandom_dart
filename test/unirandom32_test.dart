// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT


import 'package:test/test.dart';
import 'package:xrandom/src/10_random_base.dart';
import 'package:xrandom/src/xorshift128.dart';

import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/xorshift32.dart';
import 'package:xrandom/src/xorshift64.dart';

void main() {

  test('large ints are the same', () {

    // for integers larger than 32 bit, we're using hacks to handle them in JS.
    // But the results must be the same on VM and JS

    final r = Xorshift32.expected();
    expect(List.generate(20, (_) => r.nextInt(JS_MAX_SAFE_INTEGER)),  [
      2570143506677463,
      3662807060069127,
      3349799934066103,
      1431789273936353,
      6519900770844863,
      7550678221981695,
      8029895439299001,
      2570905979753821,
      767327682182935,
      6255036568723776,
      6779549608046469,
      1670834426896976,
      7621369492348606,
      1938001475236542,
      662261897641897,
      8849841925173524,
      805594492632197,
      2460066359353152,
      4840697624481462,
      7601393353604849
    ]);

  });

}

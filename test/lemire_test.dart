// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

@TestOn('vm')

import 'package:quiver/iterables.dart';
import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart';
import 'helper.dart';

void main() {

  // final r = Random();
  //
  // for (int i=0; i<100000000; ++i) {
  //   int a1 = r.nextInt(0xFFFFFFFF)+1;
  //   int b1 = r.nextInt(0xFFFFFFFF)+1;
  //
  //   int a2=a1;
  //   int b2=b1;
  //
  //   a1%=b1;
  //
  //   if (a2 >= b2) {
  //     a2 -= b2;
  //     if (a2 >= b2) {
  //       a2 %= b2;
  //     }
  //   }
  //
  //   if (a1!=a2) {
  //     print('$a1 $a2');
  //     break;
  //   }
  //
  //
  //
  //
  //
  // }
  //
  // return;


  void checkLemire(String argId, int range) {
    test('lemire $argId', () {
      final random = Xorshift64(777);
      for (var ref in enumerate(refData('lemire', argId, RefdataType.hexint).refdataInts())) {
        expect(ref.value, random.nextInt(range), reason: 'pos: ${ref.index}');
      }
    });

    test('lemire neill $argId', () {
      // the reference data is expected to be the same data as "lemire". We just check
      // that the O'Neill's "Lemire with extra tweak" returns the same as the methods
      // without tweaks
      final random = Xorshift64(777);
      for (var ref in enumerate(refData('lemire-neill', argId, RefdataType.hexint).refdataInts())) {
        expect(ref.value, random.nextInt(range));
      }
    });
  }

  checkLemire('1000', 1000);
  checkLemire('1', 1);
  checkLemire('FFx', 0xFFFFFFFF);
  checkLemire('80x', 0x80000000);
  checkLemire('7Fx', 0x7FFFFFFF);
  checkLemire("R1", 0x0f419dc8);
  checkLemire("R2", 0x32e7aeec);
}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xrandom/src/60_mulberry32.dart';
import 'package:xrandom/src/60_xorshift32.dart';

import 'helper.dart';

void main() {
  //testCommonRandom(() => Mulberry32(), ()=>Mulberry32.expected());

  checkReferenceFiles(() => Mulberry32(1), 'a');

  //Mulberry32(1).nextRaw32();

  // checkReferenceFiles(() => Mulberry32(42), 'b');
  // checkReferenceFiles(() => Mulberry32(314159265), 'c');

  // checkDoornikRandbl32(() => Mulberry32(42), 'b');
  //
  // test('expected values', () {
  //   expect(expectedList(Xorshift32.expected()),
  //       [1225539925, 51686, 0.40665327328483225, false, true, false]);
  // });
  //
  // test('Create without args', () async {
  //   final random1 = Mulberry32();
  //   await Future.delayed(Duration(milliseconds: 2));
  //   final random2 = Mulberry32();
  //
  //   expect([random1.nextRaw32(), random1.nextRaw32()],
  //       isNot([random2.nextRaw32(), random2.nextRaw32()]));
  // });
}

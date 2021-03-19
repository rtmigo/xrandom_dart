// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import "package:test/test.dart";
import 'package:xrandom/src/60_mulberry32.dart';
import 'package:xrandom/src/60_xorshift32.dart';

import 'helper.dart';

void main() {
  testCommonRandom(() => Mulberry32(), ()=>Mulberry32.expected());

  checkReferenceFiles(() => Mulberry32(1), 'a');
  checkReferenceFiles(() => Mulberry32(0), 'b');
  checkReferenceFiles(() => Mulberry32(777), 'c');
  checkReferenceFiles(() => Mulberry32(1081037251), 'd');

  // write_mulberry32("a", 1);
  // write_mulberry32("b", 0);
  // write_mulberry32("c", 777);
  // write_mulberry32("d", 1081037251u);

  test("values for JS generator", () {

    final exp = [ 1118692146,
      3456687457,
      2323025554,
      2964572940,
      4890715,
      3511320825,
      48751514,
      452846334,
      1703291702,
      2881671998 ];

    final random = Mulberry32(99);
    expect(List.generate(10, (_)=>random.nextRaw32()), exp);

  });


  //print(List.generate(3, (_)=>random.nextRaw32()));

  // 1118692146
  // 3456687457
  // 2323025554

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

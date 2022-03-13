// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

//import 'package:quiver/iterables.dart';
@TestOn('vm')
import 'package:test/test.dart';
import 'package:xrandom/src/00_ints.dart';

void main() {

  //print(1420068584772107736.truncateToDouble());

  //return;

  test('string to int', () {
    // the problem with BigInt.toInt():
    expect(BigInt.parse('0xf7d3b43bed078fa3').toInt().toHexUint64(), '7fffffffffffffff');
  });

  test('are we', () {
    expect(INT64_SUPPORTED, true);
  });

  test('lower32', () {
    expect(0x9876543277755111.lower32(), 0x77755111);
    expect(0x9876543201234567.lower32(), 0x01234567);
  });

  test('higher32', () {
    expect(0x9876543277755111.higher32(), 0x98765432);
    expect(0xFFFFFFFFFFFFFFFF.higher32(), 0xFFFFFFFF);
  });

  test('hex', () {
    expect(0xFF.toHexUint32uc(), '000000FF');
    expect(0xFF.toHexUint64uc(), '00000000000000FF');
    expect(0xFFFFFFFFFFFFFFFF.toHexUint64uc(), 'FFFFFFFFFFFFFFFF');
    expect(0x9FFFFFFFFFFFFFFF.toHexUint64uc(), '9FFFFFFFFFFFFFFF');
    expect((-1).toHexUint64uc(), 'FFFFFFFFFFFFFFFF');
    expect((-6917529027641081857).toHexUint64uc(), '9FFFFFFFFFFFFFFF');
  });

  test('signedRightShift', () {
    expect(0xFF.unsignedRightShift(4), 0xF);
    expect(0x9FFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64uc(), '09FFFFFFFFFFFFFF');
    expect(0xFFFFFFFFFFFFFFFF.unsignedRightShift(4).toHexUint64uc(), '0FFFFFFFFFFFFFFF');
  });

  //-0x180000000

  test('toUint32', () {
    // C99:
    // int64_t src = rand_uint64();
    // uint32_t dst = src;
    // printf("[%lld, %u],\n", src, dst);

    final data = [
      [-2246223750528929774, 1605201938],
      [-1879198858132331446, 1320412234],
      [1420068584772107736, 2684911064],
      [-1853238415697418041, 3560925383],
      [-1238753687981517940, 2141721484],
      [-884901738899835634, 2411721998],
      [5946077902496304465, 1092062545],
      [-4094626185386828943, 3154205553],
      [-5204503948407791159, 3406373321],
      [4855909523290242206, 3576085662],
      [-469067677300253919, 3337001761],
      [-5886259184281342436, 1762111004],
      [-5584323217517150154, 3840704566],
      [6901910564879629243, 1126857659],
      [3553810788251412412, 1085089724],
      [2789402787136675049, 1455693033],
    ];

    for (final pair in data) {
      expect(pair[0].toUint32(), pair[1], reason: '${pair[0].toRadixString(16)}');
      expect(pair[0].toUint32().toUint32(), pair[1], reason: '${pair[0].toRadixString(16)}');
    }
  });



  test('toInt32', () {
    // C99:
    // int64_t src = rand_uint64();
    // int32_t dst = src;
    // printf("[%lld, %d],\n", src, dst);

    final data = [
      [-2246223750528929774, 1605201938],
      [-1879198858132331446, 1320412234],
      [1420068584772107736, -1610056232],
      [-1853238415697418041, -734041913],
      [-1238753687981517940, 2141721484],
      [-884901738899835634, -1883245298],
      [5946077902496304465, 1092062545],
      [-4094626185386828943, -1140761743],
      [-5204503948407791159, -888593975],
      [4855909523290242206, -718881634],
      [-469067677300253919, -957965535],
      [-5886259184281342436, 1762111004],
      [-5584323217517150154, -454262730],
      [6901910564879629243, 1126857659],
      [3553810788251412412, 1085089724],
      [2789402787136675049, 1455693033],
    ];

    for (final pair in data) {
      expect(pair[0].toInt32(), pair[1], reason: '${pair[0].toRadixString(16)}');
    }
  });



  test('uint32 to int32', () {



    // 0x7ffffffd 2147483645 -> 2147483645
    // 0x7ffffffe 2147483646 -> 2147483646
    // 0x7fffffff 2147483647 -> 2147483647
    // 0x80000000 2147483648 -> -2147483648
    // 0x80000001 2147483649 -> -2147483647
    // 0x80000002 2147483650 -> -2147483646

    for (final pair in[
      [0x7ffffffd, 2147483645],
      [0x7ffffffe, 2147483646],
      [0x7fffffff, 2147483647],
      [0x80000000, -2147483648],
      [0x80000001, -2147483647],
      [0x80000002, -2147483646],
    ]) {
      expect(pair[0].uint32_to_int32(), pair[1], reason: '${pair[0].toRadixString(16)}');
      expect(pair[1].int32_as_uint32(), pair[0], reason: '${pair[0].toRadixString(16)}');
    }
  });
}

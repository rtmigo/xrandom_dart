// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

import 'package:test/test.dart';
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/00_jsnumbers.dart';

void main() {
  if (INT64_SUPPORTED) {
    // it's great: on WM we have 64 bits to test JavaScript's 53
    test('combineLower53bits on vm', () {
      expect(combineLower53bitsVM(0xFFFFFFFF, 0xFFFFFFFF) + 1, greaterThan(JS_MAX_SAFE_INTEGER));
      final r = Random();
      for (var i = 0; i < 50; ++i) {
        final a = r.nextInt(0xFFFFFFFF);
        final b = r.nextInt(0xFFFFFFFF);
        expect(combineLower53bitsVM(a, b), combineLower53bitsJS(a, b));
      }
    });

    test('combine upper bits VM', () {

      // >>> ((0x9cdd69f5<<32) | 0x07df9e6c) >> 11
      // 5519192939887603
      //
      // >>> ((0x9cdd69f5<<32) | 0x07df9e6c) <= JS_MAX_SAFE_INTEGER
      // False
      //
      // >>> ((0x9cdd69f5<<32) | 0x07df9e6c) >> 11 <= JS_MAX_SAFE_INTEGER
      // True

      expect(combineUpper53bitsVM(0x9cdd69f5, 0x07df9e6c), 5519192939887603);
    });

  }

  test('combine upper bits JS', () {
    expect(combineUpper53bitsJS(0x9cdd69f5, 0x07df9e6c), 5519192939887603);
  });

  test('exact', () {
    expect(combineLower53bitsJS(0x7cdd69f5, 0x07df9e6c), 8279275444608620);
    expect(combineLower53bitsJS(0x18155217, 0xc1c84218), 6001236499776024);
    expect(combineLower53bitsJS(0x0c26d5ad, 0x79e010c1), 1923790911049921);
  });

  test('combineLower53bits', () {
    expect(combineLower53bitsJS(0xFFFFFFFF, 0xFFFFFFFF), equals(JS_MAX_SAFE_INTEGER));

    final r = Random();
    for (var i = 0; i < 1000; ++i) {
      int x = combineLower53bitsJS(r.nextInt(0xFFFFFFFF), r.nextInt(0xFFFFFFFF));
      expect(x, greaterThanOrEqualTo(0));
      expect(x, lessThanOrEqualTo(JS_MAX_SAFE_INTEGER));
    }
  });
}



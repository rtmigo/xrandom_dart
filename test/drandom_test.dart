// SPDX-FileCopyrightText: (c) 2021-2022 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:test/test.dart';
import 'package:xrandom/xrandom.dart'; // no imports for src should be here

void main() {
  test('Drandom readme', () {
    final random = Drandom();
    expect( List.generate(5, (_) => random.nextInt(100)),
        [42, 17, 96, 23, 46] );
  });

  test('Drandom large', () {
    final random = Drandom();
    expect( List.generate(5, (_) => random.nextInt(0x7FEEDDAA)),
        [1686059242, 361797217, 1133571596, 465717623, 1522544346] );
  });

  test('Drandom nextInt range', () {
    final random = Drandom();

    expect(()=>random.nextInt(0x80000001), throwsRangeError);
    random.nextInt(0x80000000); // does not throw anything
  });

}
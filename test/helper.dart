// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import 'dart:math';

import 'package:test/test.dart';
import 'package:xorshift/src/unirandom.dart';
import 'package:xorshift/src/ints.dart';

import 'reference.dart';


String trimLeadingZeros(String s) {
  return s.replaceAll(new RegExp(r'^0+(?=.)'), '');
}

void compareWithReference32(UniRandom32 random, referenceKey) {
  final refList = referenceData[referenceKey]!;
  for (final value in refList)
  {
    final x = random.nextInt32();
    expect(trimLeadingZeros(x.toHexUint64()),trimLeadingZeros(value.toUpperCase()));
  }
}

void compareWithReference64(UniRandom64 random, referenceKey) {
  final refList = referenceData[referenceKey]!;
  for (final value in refList)
  {
    final x = random.nextInt64();
    expect(trimLeadingZeros(x.toHexUint64()),trimLeadingZeros(value.toUpperCase()));
  }
}


/// We just take a big list from our reference data, and return
/// a few values from it.
///
/// Reference data in "always ok" except if we messed up data on update.
/// This signature helps to make sure, that the reference is ok
List<String> referenceSignature(String referenceKey)
{
  List<String> list = referenceData[referenceKey]!;
  return [list[0], list[1], list[2], list[500]];
}

void testCommonRandom(Random r) {
  group("Common random ${r.runtimeType}", () {
    test("doubles", ()=>checkDoubles(r));
    test("bools", ()=>checkBools(r));
    test("ints", ()=>checkInts(r));
  });
}

void checkDoubles(Random r) {
  int countSmall = 0;
  int countBig = 0;
  int countMiddle = 0;

  const N = 10000000;
  for (int i=0; i<N; ++i)
  {
    var d = r.nextDouble();
    expect(d, greaterThanOrEqualTo(0.0));
    expect(d, lessThan(1.0));

    if (d>0.99)
      countBig++;
    else if (d<0.01)
      countSmall++;
    else if (d>=0.495 && d<0.505)
      countMiddle++;

  }

  expect(countBig, greaterThan(N/1000));
  expect(countSmall, greaterThan(N/1000));
  expect(countMiddle, greaterThan(N/1000));
}

void checkBools(Random r) {
  int countTrue = 0;

  const N = 10000000;
  for (int i = 0; i < N; ++i) {
    if (r.nextBool())
      countTrue++;
  }

  expect(countTrue, greaterThan(N * 0.4));
  expect(countTrue, lessThan(N * 0.6));

}

void checkInts(Random r)
{
  int countMin = 0;
  int countMax = 0;
  const N = 10000000;
  for (int i=0; i<N; ++i) {
    var x = r.nextInt(10);
    expect(x, greaterThanOrEqualTo(0));
    expect(x, lessThan(10));
    if (x==0)
      countMin++;
    else if (x==9)
      countMax++;
  }

  expect(countMin, greaterThan(N * 0.08));
  expect(countMin, lessThan(N * 0.12));

  expect(countMax, greaterThan(N * 0.08));
  expect(countMax, lessThan(N * 0.12));
}

List<T> skipAndTake<T>(T func(), int skip, int take) {
  for (var i=0;i<skip;++i)
    func();

  final result = <T>[];
  for (var i=0;i<take;++i)
    result.add(func());
  
  assert(result.length==take);
  return result;
}

import 'dart:math';

import 'package:test/test.dart';
import 'package:xorhift/unirandom.dart';
import 'package:xorhift/ints.dart';

import 'reference.dart';

// void compareWithReference64(UniRandom random, List<String> values) {
//   for (final value in values)
//     {
//       final x = random.next();
//       expect(x.toHexUint64().toLowerCase(),value);
//     }
// }

String trimLeadingZeros(String s) {
  return s.replaceAll(new RegExp(r'^0+(?=.)'), '');
}

void compareWithReference32(UniRandom random, referenceKey) {
  final refList = referenceData[referenceKey]!;
  for (final value in refList)
  {
    final x = random.next();
    expect(x.toRadixString(16),trimLeadingZeros(value));
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
  return [list[0], list[1], list[3], list[500]];
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

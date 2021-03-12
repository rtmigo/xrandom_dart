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
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
@TestOn('node')

import "package:test/test.dart";
import 'package:xorshift/src/errors.dart';
import 'package:xorshift/src/xorshift64.dart';
import 'package:xorshift/src/xorshift128plus.dart';

void main() {
  test("64", () {
    expect(()=>Xorshift64.deterministic(), throwsA(isA<Unsupported64Error>()));
    expect(()=>Xorshift128Plus.deterministic(), throwsA(isA<Unsupported64Error>()));

//    final random = Xorshift64(1);
  //  compareWithReference(random, "xorshift64 (seed 1)");
  });
}


import 'package:xrandom/src/00_ints.dart';
void main() {
  for (int range=1; range<=10; ++range) {
    int t = (-range).int32_to_uint32() % range;
    print("$t $range");
  }
}
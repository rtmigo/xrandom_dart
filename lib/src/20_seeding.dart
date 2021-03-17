// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

@pragma('vm:prefer-inline')
int mess2to64A(int a, int b) {
  // "The mix method was inspired by the mixing step of the lcg64_shift random engine"
  // <https://medium.com/@jeneticsga/creating-random-seeds-with-java-3df09bd02188>
  var c = a ^ b;
  c ^= c << 17;
  c ^= c >> 31;
  c ^= c << 8;
  return c;
}

@pragma('vm:prefer-inline')
int mess2to64B(int b, int a) {
  // Same as [mess2to64A], but with arguments swapped.
  var c = a ^ b;
  c ^= c << 17;
  c ^= c >> 31;
  c ^= c << 8;
  return c;
}

@pragma('vm:prefer-inline')
int mess2to64C(int a, int b) {
  return mess2to64A(a + 0xb35a6012, b * 0xdcde19b9);
}

@pragma('vm:prefer-inline')
int mess2to64D(int a, int b) {
  return mess2to64B(a + 0x93999086, b * 0x87b4f97a);
}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


// declaring int64 as BigInt to avoid JavaScript compilation errors


final int INT64_LOWER_7_BYTES = BigInt.parse("0x00FFFFFFFFFFFFFF").toInt();
final int INT64_MAX_POSITIVE = BigInt.parse("0x7FFFFFFFFFFFFFFF").toInt();
const UINT32_MAX = 0xFFFFFFFF;
const INT64_SUPPORTED = (1<<62) > (1<<61); // false for JS, true for others



extension BitInt on int {

  int unsetHighestBit64() {
    return this & INT64_MAX_POSITIVE;
  }

  int lower32() {
    return this & UINT32_MAX;
  }

  int higher32() {
    return this.unsignedRightShift(32);
  }


  /// Simulates result of `x >> shift` as if `x` were `uint64_t` in C.
  int unsignedRightShift_long(int shift) {

    // the difference between int64 and uint64 is that
    // uint64 will shift all 64 of its bits,
    // but int64 will shift lower 63 and preserve the highest bit

    if (this >= 0)
      return this >> shift;
    else {
      int x = this;
      // setting highest bit to zero
      x &= INT64_MAX_POSITIVE;
      assert(x >= 0);
      // shifting all except the highest
      x >>= shift;
      // restoring the highest bit at proper position
      x |= 1 << (63 - shift);
      return x;
    }
  }


  int unsignedRightShift(int shift) {

    // as of 2021 Dart does not have neither unsigned 64-bit integers or the ">>>"
    // unsigned right shift that can be found in Java or JavaScript
    //
    // The difference between int64 and uint64 is that
    // uint64 will shift all 64 of its bits,
    // but int64 will shift lower 63 and preserve the highest bit

    if (this >= 0)
      return this >> shift;
    else {
      int x = this;
      // setting highest bit to zero
      x &= INT64_MAX_POSITIVE;
      assert(x >= 0);
      // shifting all except the highest
      x >>= shift;
      // restoring the highest bit at proper position
      x |= 1 << (63 - shift);
      return x;
    }

    // Here is a discussion about implementing >>> in Dart
    // https://github.com/dart-lang/language/issues/478
    //
    // (this >> count) & ~(-1 << (64 - count))
    //    seems to be OK (not tested in JS)
    //
    //  ((this >= 0) ? this >> (n) : ~(~this >> (n)))
    //    not tested
    //
    // Here is also my first one-liner:
    //   this >= 0 ? this >> shift : ((this & INT64_MAX_POSITIVE) >> shift) | (1 << (63 - shift))
  }


  String toHexUint32() {
    return this.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  String toHexUint64() {

    if (this>=0)
      return this.toRadixString(16).toUpperCase().padLeft(16, '0');

    int lower7bytes = this & INT64_LOWER_7_BYTES;
    String strLow = lower7bytes.toRadixString(16).toUpperCase().padLeft(14, '0');

    // setting highest bit to zero
    int x = this;
    x &= INT64_MAX_POSITIVE;
    assert(x >= 0);

    // making it the lowest byte
    int upperByte = (x>>56)&0xFF;

    // adding the highest bit to the byte
    upperByte|=(1<<7);

    String strHigh = upperByte.toRadixString(16).toUpperCase().padLeft(2, '0');

    return strHigh+strLow;
  }
}

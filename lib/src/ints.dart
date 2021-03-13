// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

// declaring int64 as BigInt to avoid JavaScript compilation errors


final int INT64_LOWER_7_BYTES = BigInt.parse("0x00FFFFFFFFFFFFFF").toInt();
final int INT64_MAX_POSITIVE = BigInt.parse("0x7FFFFFFFFFFFFFFF").toInt();
const MAX_UINT32 = 0xFFFFFFFF;
const INT64_SUPPORTED = (1<<62) > (1<<61); // false for JS, true for others



extension BitInt on int {

  int unsetHighestBit64() {
    return this & INT64_MAX_POSITIVE;
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

    // the difference between int64 and uint64 is that
    // uint64 will shift all 64 of its bits,
    // but int64 will shift lower 63 and preserve the highest bit

    return this >= 0 ? this >> shift : ((this & INT64_MAX_POSITIVE) >> shift) | (1 << (63 - shift));

//     if (this >= 0)
//       return this >> shift;
//     else {
//       int x = this;
//       // setting highest bit to zero
//       return ((x & 0x7FFFFFFFFFFFFFFF)>>shift)|(1 << (63 - shift));
//       //assert(x >= 0);
//       // shifting all except the highest
// //      x >>= shift;
//       // restoring the highest bit at proper position
//   //    x |= 1 << (63 - shift);
//       return x;
//    }
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

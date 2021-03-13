// SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: BSD-3-Clause

const int MAX_POSITIVE_INT64 = 0x7FFFFFFFFFFFFFFF;
const MAX_UINT32 = 0xFFFFFFFF;

extension BitInt on int {

  int unsetHighestBit64() {
    return this & 0x7FFFFFFFFFFFFFFF;
  }

  /// Simulates result of `x >> shift` as if `x` were `uint64_t` in C.
  int signedRightShift(int shift) {

    // the difference between int64 and uint64 is that
    // uint64 will shift all 64 of its bits,
    // but int64 will shift lower 63 and preserve the highest bit

    if (this >= 0)
      return this >> shift;
    else {
      int x = this;
      // setting highest bit to zero
      x &= 0x7FFFFFFFFFFFFFFF;
      assert(x >= 0);
      // shifting all except the highest
      x >>= shift;
      // restoring the highest bit at proper position
      x |= 1 << (63 - shift);
      return x;
    }
  }

  String toHexUint32() {
    return this.toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  String toHexUint64() {

    if (this>=0)
      return this.toRadixString(16).toUpperCase().padLeft(16, '0');

    int lower7bytes = this&0x00FFFFFFFFFFFFFF;
    String strLow = lower7bytes.toRadixString(16).toUpperCase().padLeft(14, '0');

    // setting highest bit to zero
    int x = this;
    x &= 0x7FFFFFFFFFFFFFFF;
    assert(x >= 0);

    // making it the lowest byte
    int upperByte = (x>>56)&0xFF;

    // adding the highest bit to the byte
    upperByte|=(1<<7);

    String strHigh = upperByte.toRadixString(16).toUpperCase().padLeft(2, '0');

    return strHigh+strLow;
  }
}

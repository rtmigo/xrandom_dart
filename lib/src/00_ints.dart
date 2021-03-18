// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

// declaring int64 as int.parse to avoid JavaScript compilation errors
final int INT64_LOWER_7_BYTES = int.parse('0x00FFFFFFFFFFFFFF');
final int INT64_MAX_POSITIVE = int.parse('0x7FFFFFFFFFFFFFFF');
const UINT32_MAX = 0xFFFFFFFF;
const INT64_SUPPORTED =
    (1 << 62) > (1 << 61); // true for 64-bit systems (not for JS)
const JS_MAX_SAFE_INTEGER = 9007199254740991;

extension BitInt on int {

  @pragma('vm:prefer-inline')
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
  @pragma('vm:prefer-inline')
  int unsignedRightShift(int shift) {
    // as of 2021 Dart does not have neither unsigned 64-bit integers or the ">>>"
    // unsigned right shift that can be found in Java or JavaScript
    //
    // The difference between int64 and uint64 is that
    // uint64 will shift all 64 of its bits,
    // but int64 will shift lower 63 and preserve the highest bit

    return (this >> shift) & ~(-1 << (64 - shift));

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
    return this.toRadixString(16).padLeft(8, '0');
  }

  String toHexUint64() {
    if (this >= 0) {
      return this.toRadixString(16).padLeft(16, '0');
    }

    int lower7bytes = this & INT64_LOWER_7_BYTES;
    String strLow = lower7bytes.toRadixString(16).padLeft(14, '0');

    // setting highest bit to zero
    int x = this;
    x &= INT64_MAX_POSITIVE;
    assert(x >= 0);

    // making it the lowest byte
    int upperByte = (x >> 56) & 0xFF;

    // adding the highest bit to the byte
    upperByte |= (1 << 7);

    String strHigh = upperByte.toRadixString(16).padLeft(2, '0');

    return strHigh + strLow;
  }

  String toHexUint32uc() => this.toHexUint32().toUpperCase(); // todo remove
  String toHexUint64uc() => this.toHexUint64().toUpperCase(); // todo remove

  /// C-like conversion from value typed `uint32_t` to `int32_t`.
  @pragma('vm:prefer-inline')
  int uint32_to_int32() {
    assert(this>=0);
    assert(this<=0xFFFFFFFF);
    if (this<=0x7fffffff) {
      return this;
    }
    else {
      // (1<<32) will fail on JS, but constant is OK
      return this-0x100000000;
    }
  } //

  /// ??? C-like conversion from value typed `int32_t` to `uint32_t`.
  ///
  ///
  /// ``` C
  /// for (int i=3; i>=-3; --i)
  ///    printf("%d -> %u\n", i, i);
  /// for (int i=-0x80000000+2; i>=-0x80000000-3; --i)
  ///    printf("%d -> %u\n", i, i);
  /// }
  ///
  /// 3 -> 3
  /// 2 -> 2
  /// 1 -> 1
  /// 0 -> 0
  /// -1 -> 4294967295
  /// -2 -> 4294967294
  /// -3 -> 4294967293
  /// -2147483646 -> 2147483650
  /// -2147483647 -> 2147483649
  /// -2147483648 -> 2147483648
  /// 2147483647 -> 2147483647
  /// 2147483646 -> 2147483646
  /// 2147483645 -> 2147483645
  @pragma('vm:prefer-inline')
  int int32_as_uint32() {
    assert(this>=-0x80000000);
    assert(this<=0x7FFFFFFF);
    if (this>=0) {
      return this;
    }
    else {
      return (1<<32)+this;
    }
  }




  /// ??? C-like conversion from value typed `int32_t` to `uint32_t`.
  ///
  /// ``` C
  ///   int32_t x = ...;
  ///   return (uint32_t)x;
  /// ```
  @pragma('vm:prefer-inline')
  int int32_to_uint32() {
    assert(this>=-0x80000000);
    assert(this<=0x7FFFFFFF);
    if (this>=0) {
      return this;
    }
    else {
      return (1<<32)+this;
    }
  }


}

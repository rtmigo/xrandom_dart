extension BitInt on int {

  int signedRightShift(int shift) {
    // todo unit test
    int x = this;
    if (this >= 0)
      return x >> shift;
    else {
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

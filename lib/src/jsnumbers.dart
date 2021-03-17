/// Takes two uint32 values, combines them into one uint64 value and returns
/// lower 53 bits from it.
@pragma('vm:prefer-inline')
int combineLower53bitsVM(int high, int low) {
  // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  return ((high & 0x001fffff) << 32) | low;
}

/// Takes two uint32 values, combines them into one uint64 value and returns
/// lower 53 bits from it.
int combineLower53bitsJS(int high, int low) {
  // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  // for some reason we cannot just (<<32) in JS
  return ((high & 0x001fffff) * 4294967296) + low;
}

/// Takes two uint32 values, combines them into one uint64 value and returns
/// higher 53 bits from it shifted to the right.
@pragma('vm:prefer-inline')
int combineUpper53bitsVM(int high, int low) {

  // (0xFFFFFFFFFFFFFFFF >> 10) <= JS_MAX_SAFE_INTEGER   False
  // (0xFFFFFFFFFFFFFFFF >> 11) <= JS_MAX_SAFE_INTEGER   True

  // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  final i64 = (high<< 32) | low;
  const shift = 11;
  return (i64 >> shift) & ~(-1 << (64 - shift)); // i64 >>> shift
}

int combineUpper53bitsJS(int high, int low) {

  low>>=11; // this also freed up 11 bits at top of it

  // lowest 11 bits of high must become upper 11 bits of low
  low|=(high&0x7ff)<<(32-11);

  return (high>>11)*4294967296 + low;



  // // (0xFFFFFFFFFFFFFFFF >> 10) <= JS_MAX_SAFE_INTEGER   False
  // // (0xFFFFFFFFFFFFFFFF >> 11) <= JS_MAX_SAFE_INTEGER   True
  //
  // // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  // final i64 = (high<< 32) | low;
  // const shift = 11;
  // return (i64 >> shift) & ~(-1 << (64 - shift)); // i64 >>> shift
}


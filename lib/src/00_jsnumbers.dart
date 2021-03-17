// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'package:xrandom/src/00_errors.dart';
import 'package:xrandom/src/00_ints.dart';

/// Takes two uint32 values, combines them into one uint64 value and returns
/// lower 53 bits from it.
@pragma('vm:prefer-inline')
int combineLower53bitsVM(int high, int low) {
  // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  if (!INT64_SUPPORTED) {
    throw Unsupported64Error();
  }
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
  if (!INT64_SUPPORTED) {
    throw Unsupported64Error();
  }

  // (0xFFFFFFFFFFFFFFFF >> 10) <= JS_MAX_SAFE_INTEGER   False
  // (0xFFFFFFFFFFFFFFFF >> 11) <= JS_MAX_SAFE_INTEGER   True

  // the JS_MAX_SAFE_INTEGER is 001f ffff ffff ffff
  final i64 = (high << 32) | low;
  const shift = 11;
  return (i64 >> shift) & ~(-1 << (64 - shift)); // i64 >>> shift
}

/// Takes two uint32 values, combines them into one uint64 value and returns
/// higher 53 bits from it shifted to the right.
int combineUpper53bitsJS(int high, int low) {
  low >>= 11; // this also set to zeros higher 11 of it

  // lowest 11 bits of high must become upper 11 bits of low
  low |= (high & 0x7ff) << (32 - 11);

  return (high >> 11) * 4294967296 + low;
}

// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

import 'package:quiver/iterables.dart';
import 'package:test/test.dart';
import 'package:xrandom/src/00_errors.dart';
import 'package:xrandom/src/00_ints.dart';
import 'package:xrandom/src/21_base32.dart';
import 'package:xrandom/src/21_base64.dart';

import 'data/generated2.dart';

const FAST = INT64_SUPPORTED;

//enum RefdataType { hexint, double_mult, double_cast, doornik_randbl_32 }

// List<int> refInts(String sampleClass, String sampleName) {
//   for (final m in referenceData) {
//     if (m['sample_class'] == sampleClass &&
//         m['sample_name'] == sampleName) {
//
//     }
//
// }

Map refData(String algo, String seedId) {

  switch (algo) {
    case 'xoshiro256pp':
      algo = 'xoshiro256++';
      break;
    case 'xoshiro128pp':
      algo = 'xoshiro128++';
      break;
    case 'xorshift128p':
      algo = 'xorshift128+';
      break;

  }

  // String suffix;
  // switch (type) {
  //   case RefdataType.hexint:
  //     suffix = 'int';
  //     break;
  //   case RefdataType.double_mult:
  //     suffix = 'double_mult';
  //     break;
  //   case RefdataType.double_cast:
  //     suffix = 'double_vigna_memcast';
  //     break;
  //   case RefdataType.doornik_randbl_32:
  //     suffix = 'doornik_randbl_32';
  //     break;
  // }

  for (final m in referenceData) {
    if (m['sample_class'] == algo &&
        m['sample_name'] == seedId //&&
    //#    m['type'] == suffix
    )
    {
      return m;
    }
  }
  throw Exception('Not found [$algo] [$seedId]');
}

extension RdataExt on Map {
  Iterable<int> refdataInts() => (this['uint'] as List<String>).map((s) => int.parse(s, radix: 16));

  Iterable<String> uintsAsStrings() {
    return this['uint'];
  }
  

  Iterable<double> doornik() =>
      (this['double_doornik_randbl32'] as List<String>)
          .map((s) => double.parse(s));

  Iterable<double> double_memcast() =>
      (this['double_vigna_bitcast'] as List<String>)
          .map((s) => double.parse(s));

  Iterable<double> double_multi() =>
      (this['double_vigna_multiplication'] as List<String>)
          .map((s) => double.parse(s));


//{
  //   for (var line in m['values']) {
  //     yield int.parse(line);
  //   }  
}

// Iterable<double> loadDoubles(Map m) sync* {
//   for (var line in m['values']) {
//     yield double.parse(line);
//   }
// }



void checkDoornikRandbl32(RandomBase32 Function() createRandom, String seedId) {
  test('doornik_randbl_32 ${createRandom().runtimeType} seedId=$seedId', ()
  {
    final random = createRandom();
    final filePrefix = random.runtimeType.toString().toLowerCase();
    final values = refData(filePrefix, seedId).doornik();
    for (final refItem in enumerate(values)) {
      assert(0<=refItem.value);
      assert(refItem.value<1.0);
      expect(random.nextFloat(), refItem.value,
          reason: 'refitem ${refItem.index}');
    }
  });
}


void checkReferenceFiles(RandomBase32 Function() createRandom, String seedId) {
  group('Reference data ${createRandom().runtimeType} seedId=$seedId', () {
    late RandomBase32 random;
    late String filePrefix;

    setUp(() {
      random = createRandom();
      filePrefix = random.runtimeType.toString().toLowerCase();
    });

    test('nextRawXx', () {
      bool is64 = createRandom() is RandomBase64;

      final values = refData(filePrefix, seedId).uintsAsStrings();
      for (final item in enumerate(values)) {
        final hex = is64
            ? (random as RandomBase64).nextRaw64().toHexUint64()
            : random.nextRaw32().toHexUint32();
        expect(hex, item.value, reason: 'item ${item.index}');
      }
    });


    test('toDouble', () {
      final values =  (random is RandomBase64)
          ? refData(filePrefix, seedId).double_multi()
          : refData(filePrefix, seedId).double_memcast();
      int idx = 0;
      for (final value in values) {
        expect(random.nextDouble(), value, reason: 'item ${idx++}');
      }
    });


    if (createRandom() is RandomBase64) {
      test('nextDoubleBitcast', () {
        final values =
            refData(filePrefix, seedId).double_memcast();
        int idx = 0;
        for (final value in values) {
          expect((random as RandomBase64).nextDoubleBitcast(), value,
              reason: 'item ${idx++}');
        }
      });
    }


  });
}

List expectedList(RandomBase32 r) => [
      (r is RandomBase64) ? r.nextRaw64() : r.nextRaw32(),
      r.nextInt(100000),
      r.nextDouble(),
      r.nextBool(),
      r.nextBool(),
      r.nextBool()
    ];

String trimLeadingZeros(String s) {
  return s.replaceAll(RegExp(r'^0+(?=.)'), '');
}

void testCommonRandom(RandomBase32 Function() createRandom, RandomBase32 Function() createExpectedRandom) {
  group('Common random ${createRandom().runtimeType}', () {

    test('nextDouble', () => checkDoubles(createRandom(), true));
    test('nextFloat', () => checkDoubles(createRandom(), false));

    test('bools', () => checkBooleans(createRandom()));
    test('ints', () => checkIntegers(createRandom()));

    test('ints when power of two', () {
      final r = createExpectedRandom();
      bool zeroFound = false;
      for (int i=0; i<1000; ++i)
        {
          int x = r.nextInt(128);
          expect(x, greaterThanOrEqualTo(0));
          expect(x, lessThan(128));
          if (x==0) {
            zeroFound = true;
          }
        }
      expect(zeroFound, isTrue);
    });


    test('Seed is different each time', () {
      // even with different seeds, we can get rare matches of results.
      // But most of the the results should be unique
      expect(
          List.generate(100, (index) => createRandom().nextDouble())
              .toSet()
              .length,
          greaterThan(90));
    });

    // test('Huge ints: (1<<32)',
    //     () => checkHugeInts(createRandom(), 4294967296));
    // // "the fast case for powers of two"
    // test('Huge ints: 0x80000000',
    //     () => checkHugeInts(createRandom(), 0x80000000));
    //
    // test('Huge ints: JS_MAX_SAFE_INTEGER',
    //         () => checkHugeInts(createRandom(), JS_MAX_SAFE_INTEGER));
    //
    // if (INT64_SUPPORTED) {
    //   test('Huge ints: 0x7FFFFFFFFFFFFFFF',
    //           () => checkHugeInts(createRandom(), int.parse('0x7FFFFFFFFFFFFFFF')));
    // }



    test('nextIntCheckRange', () {
      final r = createRandom();
      expect(() => r.nextInt(-1), throwsRangeError);
      expect(() => r.nextInt(0), throwsRangeError);
      expect(() => r.nextInt(0xFFFFFFFF+1), throwsRangeError);
      // if (INT64_SUPPORTED) {
      //   r.nextInt(0xFFFFFFFF + 1); // no errors
      // } else {
      //   expect(() => r.nextInt(0xFFFFFFFF + 1), throwsRangeError);
      // }

      // no errors
      r.nextInt(1);
      r.nextInt(0xFFFFFFFF);
    });

    test('nextInt(2) works almost like next bool', () {
      final r = createRandom();

      int countZeroes = 0;
      int countOnes = 0;

      const N = 100000 * (FAST ? 10 : 1);
      for (int i = 0; i < N; ++i) {
        var x = r.nextInt(2);
        expect(x, greaterThanOrEqualTo(0.0));
        expect(x, lessThan(2.0));

        if (x == 0) {
          countZeroes++;
        } else if (x == 1) {
          countOnes++;
        } else {
          throw AssertionError();
        }
        ;
      }

      expect(countZeroes, greaterThan(N * 0.3));
      expect(countOnes, greaterThan(N * 0.3));
    });

    test('nextInt(1) returns all zeros', () {
      final r = createRandom();

      const N = 1000;
      for (int i = 0; i < N; ++i) {
        var x = r.nextInt(1);
        expect(x, 0);
      }
    });

    test('next32 <-> next64', () {

      // we don't specify, whether the generator 64 bit or 32 bit,
      // so which method returns the generator output and which
      // returns the split or combined value

      if (!INT64_SUPPORTED) {
         expect(()=>createExpectedRandom().nextRaw64(), throwsA(isA<Unsupported64Error>()));
         return;
      }

      // It must work both ways equally

      final random1 = createExpectedRandom();
      int a64 = random1.nextRaw64();
      int b64 = random1.nextRaw64();

      final random2 = createExpectedRandom();
      expect(random2.nextRaw32(), a64.higher32());
      expect(random2.nextRaw32(), a64.lower32());
      expect(random2.nextRaw32(), b64.higher32());
      expect(random2.nextRaw32(), b64.lower32());
    });

    // test('nextFloat roughly compares to nextDouble', () {
    //   final r1 = createRandom();
    //   final r2 = createRandom();
    //
    //   const N = 1000;
    //   for (int i = 0; i < N; ++i) {
    //     final d = r1.nextDouble();
    //     var x = r.nextInt(1);
    //     expect(x, 0);
    //   }
    // });
  });
}

void checkDoubles(RandomBase32 r, bool dbl) {
  int countSmall = 0;
  int countBig = 0;
  int countMiddle = 0;

  const N = 1000000 * (FAST ? 10 : 1);

  for (int i = 0; i < N; ++i) {
    var d = (dbl) ? r.nextDouble() : r.nextFloat();
    expect(d, greaterThanOrEqualTo(0.0));
    expect(d, lessThan(1.0));

    if (d > 0.99) {
      countBig++;
    } else if (d < 0.01) {
      countSmall++;
    } else {
      if (d >= 0.495 && d < 0.505) countMiddle++;
    }
  }

  expect(countBig, greaterThan(N / 1000));
  expect(countSmall, greaterThan(N / 1000));
  expect(countMiddle, greaterThan(N / 1000));
}

void checkBooleans(Random r) {
  int countTrue = 0;

  const N = 1000000 * (FAST ? 10 : 1);

  for (int i = 0; i < N; ++i) {
    if (r.nextBool()) countTrue++;
  }

  expect(countTrue, greaterThan(N * 0.4));
  expect(countTrue, lessThan(N * 0.6));
}

void checkIntegers(Random r) {
  int countMin = 0;
  int countMax = 0;

  const N = 1000000 * (FAST ? 10 : 1);

  for (int i = 0; i < N; ++i) {
    var x = r.nextInt(10);
    expect(x, greaterThanOrEqualTo(0));
    expect(x, lessThan(10));
    if (x == 0) {
      countMin++;
    } else if (x == 9) {
      countMax++;
    }
  }

  expect(countMin, greaterThan(N * 0.08));
  expect(countMin, lessThan(N * 0.12));

  expect(countMax, greaterThan(N * 0.08));
  expect(countMax, lessThan(N * 0.12));
}

void checkHugeInts(Random r, final int upper) {
  // check that when we choose a large value of upper,
  // - we're never cross the margins
  // - we're are getting values close the margin

  int countAlmostTop = 0;
  const N = 1000000 * (FAST ? 10 : 1);

  for (int i = 0; i < N; ++i) {
    var x = r.nextInt(upper);
    expect(x, greaterThanOrEqualTo(0));
    expect(x, lessThan(upper));
    if (x >= upper * 0.9) {
      countAlmostTop++;
    }
  }

  expect(countAlmostTop, greaterThan(N * 0.05));
}

List<T> skipAndTake<T>(T Function() func, int skip, int take) {
  for (var i = 0; i < skip; ++i) {
    func();
  }

  final result = <T>[];
  for (var i = 0; i < take; ++i) {
    result.add(func());
  }

  assert(result.length == take);
  return result;
}

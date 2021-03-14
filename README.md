![Generic badge](https://img.shields.io/badge/status-draft-red.svg)
[![Actions Status](https://github.com/rtmigo/xorshift/workflows/unittest/badge.svg?branch=master)](https://github.com/rtmigo/xorshift/actions)
![Generic badge](https://img.shields.io/badge/tested_on-Windows_|_MacOS_|_Ubuntu-blue.svg)
![Generic badge](https://img.shields.io/badge/tested_on-VM_|_JS-blue.svg)

# [xorshift](https://github.com/rtmigo/xorshift)

This library implements [Xorshift](https://en.wikipedia.org/wiki/Xorshift) random number generators
in Dart.

Xorshift algorithms are known among the **fastest random number generators**, requiring very small
code and state.

# Speed

Generating 100 million of random numbers with AOT-compiled binary. 

| Time (lower is better)              | nextInt | nextDouble | nextBool |
|--------------------|---------|------------|----------|
| Random (dart:math) |  2407   |    3227    |   2329   |
| Xorshift32         |  1253   |    1955    |   1506   |
| Xorshift64         |  2011   |    2228    |   1405   |
| Xorshift128        |  1862   |    3321    |   1518   |
| Xorshift128Plus    |  2086   |    3064    |   1419   |

Oh yeah.

# Simplicity

All classes implement the standard [`Random`](https://api.dart.dev/stable/2.12.1/dart-math/Random-class.html).  They can be used in the same way.

``` dart
import 'package:xorshift/xorshift.dart';

Random random = Xorshift();

var a = random.nextBool(); 
var b = random.nextDouble();
var c = random.nextInt(n);
```

# Determinism

Xorshift's classes have a `deterministic` method. By creating the object like that, you'll get same 
sequence of numbers every time.

``` dart
test('my test', () {
    final predictablyRandom = Xorshift.deterministic();
    // run this test twice ;)
    expect(predictablyRandom.nextInt(1000), 119);
    expect(predictablyRandom.nextInt(1000), 240);
    expect(predictablyRandom.nextInt(1000), 369);    
});    
```

You can achieve about the same by creating the `Random` with a `seed` argument. However, the unchangeable
seed does not protect you from `dart:math` implementation updates. In contrast to this,
*xorshift32* is a very specific algorithm. Therefore, the predictability of the
Xorshift's `deterministic`
sequences can be relied upon. *(but not until the library reaches stable release status)*



# Compatibility

| Class                            | 64-bit platforms | JavaScript |
|----------------------------------|------------------|------------|
| `Xorshift` aka `Xorshift32`      | yes              | yes        |
| `Xorshift128`                    | yes              | yes        |
| `Xorshift64`                     | yes              | no         |
| `Xorshift128Plus`                | yes              | no         |

The library has been thoroughly **tested to match reference numbers** generated by C algorithms. The
sources in C are taken directly from scientific publications by George Marsaglia and Sebastiano
Vigna, the inventors of the algorithms. The Xorshift128+ results are also matched to reference
values from JavaScript [xorshift](https://github.com/AndreasMadsen/xorshift) library, that tested
the 128+ similarly.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu** and **macOS** in **VM** and **Node.js** modes.
 
# Classes

| Class             | Algorithm    | Author           | Year |
|-------------------|--------------|------------------|------|
| `Xorshift`        | xorshift32   | George Marsaglia | 2003 |
| `Xorshift32`      | xorshift32   | George Marsaglia | 2003 |
| `Xorshift64`      | xorshift64   | George Marsaglia | 2003 |
| `Xorshift128`     | xorshift128  | George Marsaglia | 2003 |
| `Xorshift128Plus` | xorshift128+ | Sebastiano Vigna | 2015 |

--

# Speed optimizations

The `nextDoubleFast()` is a lightning fast mapping of 32-bit integers to a `double` in reduced detail.

| Time (lower is better)              | nextDouble | nextDoubleFast |
|--------------------|------------|----------------|
| Random (dart:math) |    3227    |       -        |
| Xorshift32         |    1955    |      694       |
| Xorshift64         |    2228    |      1341      |
| Xorshift128        |    3321    |      1309      |
| Xorshift128Plus    |    3064    |      1387      |

The `nextInt32()` and `nextInt64()` do not accept any arguments. They return the raw output of the RNGs.

``` dart 
xorshift.nextInt32();  // 32-bit unsigned 
xorshift.nextInt64();  // 64-bit signed
```

| Time (lower is better) | nextInt | nextInt32 | nextInt64 |
|--------------------|---------|-----------|-----------|
| Random (dart:math) |  2407   |     -     |     -     |
| Xorshift32         |  1253   |    780    |     -     |
| Xorshift64         |  2011   |   1367    |   1394    |
| Xorshift128        |  1862   |   1344    |     -     |
| Xorshift128Plus    |  2086   |   1424    |   1533    |

-----
All the benchmarks on this page are from AOT-compiled binaries running on AMD A9-9420e with Ubuntu 20.04.
Time is measured in milliseconds.

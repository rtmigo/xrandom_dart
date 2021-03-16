[![Actions Status](https://github.com/rtmigo/xrandom/workflows/unittest/badge.svg?branch=master)](https://github.com/rtmigo/xrandom/actions)
![Generic badge](https://img.shields.io/badge/tested_on-Windows_|_MacOS_|_Ubuntu-blue.svg)
![Generic badge](https://img.shields.io/badge/tested_on-VM_|_JS-blue.svg)
[![Pub Package](https://img.shields.io/pub/v/xrandom.svg)](https://pub.dev/packages/xrandom)

# [xrandom](https://github.com/rtmigo/xrandom)

Classes implementing all-purpose, rock-solid **random number generators**.

Library priorities:
- generation of identical bit-accurate numbers regardless of the platform
- reproducibility of the same random results in the future
- high-quality randomness
- performance

Algorithms are [Xoshiro](https://prng.di.unimi.it/) for **quality** and 
[Xorshift](https://en.wikipedia.org/wiki/Xorshift) for **speed**.

# Speed

Generating 50 million random numbers with AOT-compiled binary. 

| Time (lower is better) | nextInt | nextDouble | nextBool |
|------------------------|---------|------------|----------|
| Random (dart:math)     |  1172   |    1541    |   1134   |
| Xrandom             |   732   |    1122    |   718    |


# Simplicity

It's compatible with the standard [`Random`](https://api.dart.dev/stable/2.12.1/dart-math/Random-class.html)

``` dart
import 'package:xrandom/xrandom.dart';

final random = Xrandom();

var a = random.nextBool(); 
var b = random.nextDouble();
var c = random.nextInt(n);

var unordered = [1, 2, 3, 4, 5]..shuffle(random);
```

# Reproducibility

Xrandom's classes can also be created with `expected` method.
It is made specifically for testing. 

``` dart
test('my test', () {
  final random = Xrandom.expected();
  // you'll get same sequence of numbers every time
  expect(random.nextInt(1000), 925);
  expect(random.nextInt(1000), 686);
  expect(random.nextInt(1000), 509);  
});    
```

You can achieve the same determinism by creating the `Random` with a `seed` argument. However, this does
not protect you from `dart:math` implementation updates.

The sequences produced by the `expected()` generators are intended to be reproducible.

*(but not until the library reaches stable release status)*

# Aliases

In most cases, you can just use the `Xrandom` class. This is an easy-to-remember
alias for a fast and compatible algorithm.

| Class        | Is the same as | Works on                     |
|--------------|----------------|------------------------------|
| `Xrandom`    | `Xorshift32`   | Everywhere                   |
| `Xrandom64`  | `Xorshift128p` | Everywhere except JavaScript |

`Xrandom64` is a more modern and advanced generator. 
On the other hand, `Xrandom` is lightning fast.


# Classes

| Class             | Arch | Algorithm  |   Algorithm author | Published |
|-------------------|------|--------------|-------------|------|
| `Xorshift32`      | 32 |  [xorshift32](https://www.jstatsoft.org/article/view/v008i14)   | G. Marsaglia | 2003 |
| `Xorshift64`      | 64 | [xorshift64](https://www.jstatsoft.org/article/view/v008i14)   | G. Marsaglia | 2003 |
| `Xorshift128`     | 32 | [xorshift128](https://www.jstatsoft.org/article/view/v008i14)  | G. Marsaglia | 2003 |
| `Xorshift128p` | 64 | [xorshift128+](https://arxiv.org/abs/1404.0390) | S. Vigna | 2015 |
| `Xoshiro128pp` | 32 | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) | D. Blackman and S. Vigna | 2019 |
| `Xoshiro256pp` | 64 | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) | D. Blackman and S. Vigna | 2019 |
| `Splitmix64` | 64 | [splitmix64](https://prng.di.unimi.it/splitmix64.c) | S. Vigna | 2015 |

# What to choose

| Target                            | Mobile and Desktop | and JavaScript |
|----------------------------------|------------------|------------|
| **Speed**       | `Xorshift64`              | `Xorshift32`        |
| **Quality**     | `Xoshiro256pp`              | `Xoshiro128pp`        |

JavaScript-enabled classes are always some trade-offs in favor of compatibility.

# Compatibility

You can safely **use any classes on mobile and desktop** platforms. 

However, if you also target **JavaScript** (Web, Node.js), you will have to 
**limit your choice**.

Full compatibility table:

| Class                | Is a    | Mobile and Desktop | JavaScript |
|----------------------|---------|------------------|------------|
| **`Xorshift32`**     | 32-bit | **yes**              | **yes**        |
| **`Xorshift128`**    | 32-bit | **yes**              | **yes**        |
| **`Xoshiro128pp`**   | 32-bit   | **yes**              | **yes**         |
| `Xorshift64`         | 64-bit            | yes              | no         |
| `Xorshift128p`       | 64-bit         | yes              | no         |
| `Xoshiro256pp`       | 64-bit         | yes              | no         |
| `Splitmix64`       | 64-bit         | yes              | no         |


# Speed optimizations

### Raw bits

The `nextInt32()` and `nextInt64()` return the raw output of the generator. 

| Method | Returns | Equivalent of | 
|--------|---------|-----------|
| `nextInt32()` | 32-bit unsigned | `nextInt(0xFFFFFFFE)+1` |
| `nextInt64()` | 64-bit signed | `nextInt(0xFFFFFFFFFFFFFFFE)+1` |

| Time (lower is better) | nextInt | nextInt32 | nextInt64 |
|------------------------|---------|-----------|-----------|
| Random (dart:math)     |  1208   |     -     |     -     |
| Xorshift32             |   719   |    409    |     -     |
| Xorshift64             |  1114   |    814    |    838    |
| Xorshift128            |   907   |    618    |     -     |
| Xorshift128p           |  1162   |    854    |    952    |
| Xoshiro128pp           |  1228   |    912    |     -     |
| Xoshiro256pp           |  1746   |   1498    |   2039    |
| Splitmix64             |  1248   |    931    |    782    |

### Rough double

`nextFloat`, unlike `nextDouble`, prefers speed to accuracy. It transforms 
a single 32-bit integer into a `double`. Therefore, the result is limited 
to a maximum of 2^32-1 values. But it's still a double with four billion shades.

| Time (lower is better) | nextDouble | nextFloat |
|------------------------|------------|-----------|
| Random (dart:math)     |    1653    |     -     |
| Xorshift32             |    1126    |    407    |
| Xorshift64             |    1011    |    825    |
| Xorshift128            |    1461    |    622    |
| Xorshift128p           |    1141    |    860    |
| Xoshiro128pp           |    2095    |    923    |
| Xoshiro256pp           |    2294    |   1488    |
| Splitmix64             |    1098    |    932    |

# More benchmarks

| Time (lower is better) | nextInt | nextDouble | nextBool |
|------------------------|---------|------------|----------|
| Random (dart:math)     |  1208   |    1653    |   1177   |
| Xorshift32             |   719   |    1126    |   710    |
| Xorshift64             |  1114   |    1011    |   685    |
| Xorshift128            |   907   |    1461    |   719    |
| Xorshift128p           |  1162   |    1141    |   694    |
| Xoshiro128pp           |  1228   |    2095    |   726    |
| Xoshiro256pp           |  1746   |    2294    |   721    |
| Splitmix64             |  1248   |    1098    |   688    |

All the benchmarks on this page are from AOT-compiled binaries running on AMD A9-9420e with Ubuntu 20.04. Time is measured in milliseconds.

# Consistency

The library has been thoroughly **tested to match reference numbers** generated by C algorithms. The
sources in C are taken directly from scientific publications or the reference implementations by the inventors of the algorithms. The Xorshift128+ results are also matched to reference
values from [JavaScript xorshift library](https://github.com/AndreasMadsen/xorshift), which tested
the 128+ similarly.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu**, and **macOS** in **VM** and **Node.js** modes.


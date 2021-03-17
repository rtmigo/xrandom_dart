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
| Xrandom             |   719   |    1126    |   710    |


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

# Which to choose

If you just want a random number:

``` dart
final random = Xrandom();  // works on all platforms

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
``` 

**`Xrandom`** is **fast** and works **everywhere**.

-------

If you need billions and billions of randoms in a non-repeating sequence:

``` dart
final random = XrandomHq();  // works on mobile and desktop

for (var i=0; i<BILLIONS; i++)
    feedMonteCarloSimulation( random.nextDouble() );
```

**`XrandomHq`** is **high quality** and expected to be run on **modern platforms**.
That is, on desktops, phones and tablets. But not JavaScript.

-------

If you tried to create `XrandomHq` on Node.js but got `UnsupportedError`:

``` dart
final random = XrandomJs();  // works on all platforms

for (var i=0; i<BILLIONS; i++)  
    feedMonteCarloSimulation( random.nextDouble() ); // on JS? O_O  
```

**`XrandomJs`** is slightly less **high quality**, but works **everywhere**.


# Features

The Xrandom classes has additions compared to the system `Random`.


## Xrandom.nextFloat()

`nextFloat` generates a floating-point value in range 0.0≤x<1.0.

Unlike the `nextDouble`, `nextFloat` prefers speed to precision. 
It's still a `double` that has four billion shades, but it's much faster.

<details>
  <summary>Benchmarks</summary>

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
</details>


## Xrandom.nextInt32() and Xrandom.nextInt64()

These methods return the raw output of the generator. Depending on the algorithm, 
the output is a number consisting of either 32 random bits or 64 random bits. 

Xrandom automatically concatenates 32-bit numbers into 64-bit ones, 
and vice versa. Therefore, both methods work for all classes.
In general, this is **much faster** than `nextInt`.

| Method        | Returns         | Equivalent of                   | 
|---------------|-----------------|---------------------------------|
| `nextInt32()` | 32-bit unsigned | `nextInt(0xFFFFFFFE)+1`         |
| `nextInt64()` | 64-bit signed   | `nextInt(0xFFFFFFFFFFFFFFFE)+1` |

However, in JavaScript, integers are limited to 53 bits. So only `nextInt32()` works there.


<details>
  <summary>Benchmarks</summary>
  
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
</details>





# Algorithms

| Class             | JS | Algorithm  |   Algorithm author | Published |
|-------------------|------|--------------|-------------|------|
| `Xorshift32`      | **✓** |  [xorshift32](https://www.jstatsoft.org/article/view/v008i14)   | G. Marsaglia | 2003 |
| `Xorshift64`      | **✗** | [xorshift64](https://www.jstatsoft.org/article/view/v008i14)   | G. Marsaglia | 2003 |
| `Xorshift128`     | **✓** | [xorshift128](https://www.jstatsoft.org/article/view/v008i14)  | G. Marsaglia | 2003 |
| `Xorshift128p` | **✗** | [xorshift128+ v2](https://arxiv.org/abs/1404.0390) | S. Vigna | 2015 |
| `Xoshiro128pp` | **✓** | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) | D. Blackman and S. Vigna | 2019 |
| `Xoshiro256pp` | **✗** | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) | D. Blackman and S. Vigna | 2019 |
| `Splitmix64` | **✗** | [splitmix64](https://prng.di.unimi.it/splitmix64.c) | S. Vigna | 2015 |

| Class       | The same as       | Mobile | Desktop | JS |
|-------------|-------------------|--------|---------|----|
| `Xrandom`   | `Xorshift32`      | **✓**      | **✓**       | **✓**  |
| `XrandomHq` | `Xoshiro256pp`    | **✓**      | **✓**       | **✗**  |
| `XrandomJs` | `Xoshiro128pp`    | **✓**      | **✓**       | **✓**  |

`Xrandom`, `XrandomHq`, `XrandomJs` are easy-to-remember aliases.

# Compatibility

You can safely **use any classes on mobile and desktop** platforms. 

However, if you also target **JavaScript** (Web, Node.js), you will have to 
**limit your choice**.

Full compatibility table:

| Class                | Is a    | Mobile | Desktop | JavaScript |
|----------------------|---------|--------|---------|------------|
| **`Xorshift32`**     | 32-bit  | **✓**  | **✓**  | **✓**      |
| **`Xorshift128`**    | 32-bit  | **✓**  | **✓**  | **✓**      |
| **`Xoshiro128pp`**   | 32-bit  | **✓**  | **✓**  | **✓**      |
| `Xorshift64`         | 64-bit  | **✓**  | **✓**  | **✗**      |
| `Xorshift128p`       | 64-bit  | **✓**  | **✓**  | **✗**      |
| `Xoshiro256pp`       | 64-bit  | **✓**  | **✓**  | **✗**      |
| `Splitmix64`       | 64-bit    | **✓**  | **✓**  | **✗**      |

If you try to create a JavaScript-incompatible object in JavaScripts-compiled 
code, an `UnsupportedError` will be thrown.




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


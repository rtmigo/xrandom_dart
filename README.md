![Generic badge](https://img.shields.io/badge/tested_on-Windows_|_MacOS_|_Ubuntu-blue.svg)
![Generic badge](https://img.shields.io/badge/tested_on-VM_|_JS-blue.svg)
[![Pub Package](https://img.shields.io/pub/v/xrandom.svg)](https://pub.dev/packages/xrandom)

# [xrandom](https://github.com/rtmigo/xrandom)

Classes implementing all-purpose, rock-solid **random number generators**.

Library priorities:
- generation of identical bit-accurate numbers regardless of the platform
- reproducibility of the random results in the future
- high-quality randomness
- performance

----------

It has the same API as the standard [`Random`](https://api.dart.dev/stable/2.12.1/dart-math/Random-class.html)

``` dart
import 'package:xrandom/xrandom.dart';

final random = Xrandom();

var a = random.nextBool(); 
var b = random.nextDouble();
var c = random.nextInt(n);

var unordered = [1, 2, 3, 4, 5]..shuffle(random);
```

# Creating the object

The library provides classes that differ in the first letter: `Xrandom`, `Qrandom`, `Drandom`.

If you just want a random number:

``` dart
final random = Xrandom();

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
``` 

If you are solving a math problem:

``` dart
final random = Qrandom(); // Q is for statistical Quality

feedMonteCarloSimulation(random);
```

If you want the same numbers each time:

``` dart
final random = Drandom(); // D is for Dumb Determinism 

test("no surprises ever", () {
    expect(random.nextInt(100), 42);
    expect(random.nextInt(100), 17);
    expect(random.nextInt(100), 96);
});
```

# Speed

Generating random numbers with AOT-compiled binary.

Sorted by `nextInt` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextInt | nextDouble | nextBool |
|----|------------------------|--------:|-----------:|---------:|
| ✓  | Xrandom                |     627 |        640 |      391 |
| ✓  | **Random (dart:math)** |     895 |        929 |      662 |
| ✓  | Qrandom / Drandom      |     933 |       1219 |      398 |


# Additions to Random


## nextFloat

`nextFloat()` generates a floating-point value in range 0.0≤x<1.0.

Unlike the `nextDouble`, `nextFloat` prefers speed to precision.
It's still a `double`, but it has four billion shades instead of eight 
quadrillions.

<details>
  <summary>Speed comparison</summary>

Sorted by `nextDouble` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextDouble | nextFloat |
|----|------------------------|-----------:|----------:|
|    | Xorshift64             |        569 |       353 |
|    | Xorshift128p           |        635 |       389 |
| ✓  | Xrandom                |        640 |       221 |
|    | Splitmix64             |        658 |       398 |
| ✓  | Xorshift128            |        815 |       339 |
|    | Mulberry32             |        841 |       301 |
| ✓  | **Random (dart:math)** |        929 |           |
|    | Xoshiro256pp           |       1182 |       713 |
| ✓  | Qrandom / Drandom              |       1219 |       539 |


</details>


## nextRaw

These methods return the raw output of the generator uncompromisingly fast. Depending on the algorithm, 
the output is a number consisting of either 32 random bits or 64 random bits. 

Xrandom combines small numbers or separates large ones. The methods work with any of the generators.


| JS    | Method        | Returns         | Equivalent of                   | 
|-------|--------|-----------------|---------------------------------|
| ✓ | `nextRaw32()` | 32-bit unsigned | `nextInt(pow(2,32))`         |
| ✓ | `nextRaw53()` | 53-bit unsigned | `nextInt(pow(2,53))`         |
|   | `nextRaw64()` | 64-bit signed   | `nextInt(pow(2,64))` |


<details>
  <summary>Speed comparison</summary>
  
Sorted by `nextInt` **fastest  to slowest**  
(numbers show execution time)
  
  
| JS | Class                  | nextInt | nextRaw32 | nextRaw64 |
|----|------------------------|--------:|----------:|----------:|
| ✓  | Xrandom                |     627 |       280 |       549 |
| ✓  | Xorshift128            |     726 |       341 |       782 |
|    | Xorshift64             |     748 |       346 |       491 |
|    | Mulberry32             |     767 |       307 |       709 |
|    | Xorshift128p           |     772 |       383 |       529 |
|    | Splitmix64             |     838 |       398 |       500 |
| ✓  | **Random (dart:math)** |     895 |           |           |
| ✓  | XrandomHq              |     933 |       537 |      1186 |
|    | Xoshiro256pp           |    1138 |       703 |      1072 |


Since `nextInt`'s return range is always limited to 32 bits, 
only comparison to `nextRaw32` is "apples-to-apples".

</details>





# Algorithms

| JS | Class          | Algorithm                                                         |    Introduced | Alias |
|:--:|----------------|-------------------------------------------------------------------|:-----------------:|------|
| ✓  | `Xorshift32`   | [xorshift32](https://www.jstatsoft.org/article/view/v008i14)      | 2003 | `Xrandom` |
|    | `Xorshift64`   | [xorshift64](https://www.jstatsoft.org/article/view/v008i14)      |  2003 |
| ✓  | `Xorshift128`  | [xorshift128](https://www.jstatsoft.org/article/view/v008i14)     |  2003 |
|    | `Splitmix64`   | [splitmix64](https://prng.di.unimi.it/splitmix64.c)               |  2015 |
|    | `Xorshift128p` | [xorshift128+ v2](https://arxiv.org/abs/1404.0390)                |  2015 |
|    | `Mulberry32` | [mulberry32](https://gist.github.com/tommyettinger/46a874533244883189143505d203312c)                |  2017 |
| ✓  | `Xoshiro128pp` | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) |  2019 | `Qrandom`, `Drandom` |
|    | `Xoshiro256pp` | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) |  2019 |  |


You can use any generator from the library in the same way as in the examples with the `Xrandom` class.

``` dart
final random = Mulberry32();

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
```

# Compatibility

TL;DR `Xrandom`, `Qrandom`, `Drandom` work on all platforms. Others may not work on JS.

The library is written in pure Dart. Therefore, it works wherever Dart works.

But some of the classes really need full support for 64-bit integers. 
**JavaScript** actually only supports **53 bits**. If your target platform is JavaScript, then the selection will have to be 
narrowed down to the options marked with **[✓] checkmark in the JS column**. Trying 
to create a incompatible object in JavaScript-transpiled code will lead to `UnsupportedError`.

If your code compiles to native (like in **Flutter** apps for **Android** and **iOS**), 
**64-bit** generators will work best for you. For example, `Xorshift64` for speed or `Xoshiro256pp` for quality.

# More benchmarks

`nextInt` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextInt | nextDouble | nextBool |
|----|------------------------|--------:|-----------:|---------:|
| ✓  | Xrandom                |     627 |        640 |      391 |
| ✓  | Xorshift128            |     726 |        815 |      394 |
|    | Xorshift64             |     748 |        569 |      386 |
|    | Mulberry32             |     767 |        841 |      391 |
|    | Xorshift128p           |     772 |        635 |      394 |
|    | Splitmix64             |     838 |        658 |      392 |
| ✓  | **Random (dart:math)** |     895 |        929 |      662 |
| ✓  | Qrandom / Drandom              |     933 |       1219 |      398 |
|    | Xoshiro256pp           |    1138 |       1182 |      406 |

All the benchmarks on this page are from AOT-compiled binaries running on AMD A9-9420e with Ubuntu 20.04. Time is measured in milliseconds.

# Consistency

The library has been thoroughly **tested to match reference numbers** generated 
by the same algorithms implemented in C99. Not only `int`s, but also numbers
converted to `double` including all decimal places that the compiler takes 
into account.

The sources in C are taken directly from scientific publications or the 
reference implementations by the authors of the algorithms. 
The Xorshift128+ results are also matched to reference values from 
[JavaScript xorshift library](https://github.com/AndreasMadsen/xorshift), 
which tested the 128+ similarly.

Therefore, the sequence generated for example by the 
`Xoshiro128pp.nextRaw32()` with the seed `(1, 2, 3, 4)` is the same as the [C99 code](https://prng.di.unimi.it/xoshiro128plusplus.c) will produce with the same seed.

The `double` values will also be the same as if the upper bits of `uint64_t` type 
were converted to `double_t` in C99 by unsafe pointer casting. There are no 
pointers or unsafe conversions in Dart. Moreover, there are no upper bits `uint64_t` in JavaScript.
But `double`s are the same type everywhere, and their random values will be the same.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu**, and **macOS** in **VM** and **Node.js** modes.


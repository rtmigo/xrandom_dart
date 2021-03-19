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





Algorithms are [Xoshiro](https://prng.di.unimi.it/) for **quality** and 
[Xorshift](https://en.wikipedia.org/wiki/Xorshift) for **speed**.

----------

It's has the same API as the standard [`Random`](https://api.dart.dev/stable/2.12.1/dart-math/Random-class.html)

``` dart
import 'package:xrandom/xrandom.dart';

final random = Xrandom();

var a = random.nextBool(); 
var b = random.nextDouble();
var c = random.nextInt(n);

var unordered = [1, 2, 3, 4, 5]..shuffle(random);
```

# Creating the object

If you just want a random number:

``` dart
final random = Xrandom();

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
``` 


If you are solving a math problem:


``` dart
final random = XrandomHq();

for (var i=0; i<BILLIONS; i++)
    feedMonteCarloSimulation( random.nextDouble() );
```

# Speed

Generating random numbers with AOT-compiled binary.

Sorted by `nextInt` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextInt | nextDouble | nextBool |
|----|------------------------|--------:|-----------:|---------:|
| ✓  | Xrandom                |     626 |        626 |      410 |
| ✓  | **Random (dart:math)** |     878 |        931 |      671 |
| ✓  | XrandomHq              |     932 |       1223 |      415 |


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
not protect you from the dart:math implementation updates.

The sequences produced by the `expected()` generators are intended to be reproducible.
*But not until the library reaches 1.0.*





# Additions to Random


## nextFloat

`nextFloat` generates a floating-point value in range 0.0≤x<1.0.

Unlike the `nextDouble`, `nextFloat` prefers speed to precision.
It's still a `double`, but it has four billion shades instead on eight 
quadrillion.

<details>
  <summary>Speed comparison</summary>

Sorted by `nextDouble` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextDouble | nextFloat |
|----|------------------------|-----------:|----------:|
|    | Xorshift64             |        573 |       359 |
| ✓  | Xrandom                |        626 |       225 |
|    | Xorshift128p           |        631 |       391 |
|    | Splitmix64             |        670 |       403 |
| ✓  | Xorshift128            |        820 |       347 |
| ✓  | **Random (dart:math)** |        931 |          |
|    | Xoshiro256pp           |       1162 |       718 |
| ✓  | XrandomHq              |       1223 |       535 |


</details>


## nextRaw

These methods return the raw output of the generator uncompromisingly fast. Depending on the algorithm, 
the output is a number consisting of either 32 random bits or 64 random bits. 

Xrandom concatenates 32-bit sequences into 64-bit and vice versa. Therefore, both methods work regardless of the algorithm.


| JS    | Method        | Returns         | Equivalent of                   | 
|-------|--------|-----------------|---------------------------------|
| ✓ | `nextRaw32()` | 32-bit unsigned | `nextInt(0xffffffff)+1`         |
|   | `nextRaw64()` | 64-bit signed   | `nextInt(0xffffffffffffffff)+1` |


<details>
  <summary>Speed comparison</summary>
  
Sorted by `nextInt` **fastest  to slowest**  
(numbers show execution time)
  
  
| JS | Class                  | nextInt | nextRaw32 | nextRaw64 |
|----|------------------------|--------:|----------:|----------:|
| ✓  | Xrandom                |     626 |       224 |       543 |
| ✓  | Xorshift128            |     725 |       338 |       776 |
|    | Xorshift64             |     756 |       353 |       517 |
|    | Xorshift128p           |     774 |       385 |       534 |
|    | Splitmix64             |     840 |       398 |       497 |
| ✓  | **Random (dart:math)** |     878 |          |          |
| ✓  | XrandomHq              |     932 |       529 |      1184 |
|    | Xoshiro256pp           |    1115 |       722 |      1076 |


Since `nextInt`'s return range is always limited to 32 bits, 
only comparison to `nextRaw32` is "apples-to-apples".

</details>





# Algorithms

| JS | Class          | Algorithm                                                         |    Introduced | Alias |
|:--:|----------------|-------------------------------------------------------------------|:-----------------:|------|
| ✓  | `Xorshift32`   | [xorshift32](https://www.jstatsoft.org/article/view/v008i14)      | 2003 | `Xrandom` |
|    | `Xorshift64`   | [xorshift64](https://www.jstatsoft.org/article/view/v008i14)      |  2003 |
| ✓  | `Xorshift128`  | [xorshift128](https://www.jstatsoft.org/article/view/v008i14)     |  2003 |
|    | `Xorshift128p` | [xorshift128+ v2](https://arxiv.org/abs/1404.0390)                |  2015 |
| ✓  | `Xoshiro128pp` | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) |  2019 | `XrandomHq` |
|    | `Xoshiro256pp` | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) |  2019 |  |
|    | `Splitmix64`   | [splitmix64](https://prng.di.unimi.it/splitmix64.c)               |  2015 |

# Compatibility

The library is written in pure Dart. Therefore, it works wherever Dart works.

But among the platforms supported by Dart, there is an unusual: 
JavaScript. Numbers in JavaScript have only 53 significant bits instead of 64.
If your target platform is JavaScript, then the selection will have to be 
narrowed down to the options marked with [✓] checkmark in the JS column.

Trying to create a incompatible object in JavaScripts-transpiled code will lead to `UnsupportedError`.

# More benchmarks

`nextInt` **fastest  to slowest**
(numbers show execution time)

| JS | Class                  | nextInt | nextDouble | nextBool |
|----|------------------------|--------:|-----------:|---------:|
| ✓  | Xrandom                |     626 |        626 |      410 |
| ✓  | Xorshift128            |     725 |        820 |      410 |
|    | Xorshift64             |     756 |        573 |      380 |
|    | Xorshift128p           |     774 |        631 |      384 |
|    | Splitmix64             |     840 |        670 |      388 |
| ✓  | **Random (dart:math)** |     878 |        931 |      671 |
| ✓  | XrandomHq              |     932 |       1223 |      415 |
|    | Xoshiro256pp           |    1115 |       1162 |      402 |


All the benchmarks on this page are from AOT-compiled binaries running on AMD A9-9420e with Ubuntu 20.04. Time is measured in milliseconds.

# Consistency

The library has been thoroughly **tested to match reference numbers** generated by C algorithms. The
sources in C are taken directly from scientific publications or the reference implementations by the authors of the algorithms. The Xorshift128+ results are also matched to reference
values from [JavaScript xorshift library](https://github.com/AndreasMadsen/xorshift), which tested
the 128+ similarly.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu**, and **macOS** in **VM** and **Node.js** modes.


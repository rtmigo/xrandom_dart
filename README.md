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


# Speed

Generating 50 million random numbers with AOT-compiled binary. 

| Time (lower is better) | nextInt | nextDouble | nextBool |
|------------------------|---------|------------|----------|
| Xrandom             |   628   |    628    |   407    |
| Random (dart:math)     |  878   |    929    |   661   |






# Which to choose

If you just want a random number:

``` dart
final random = Xrandom();  // works on all platforms

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
``` 

**`Xrandom`** class is **fast** and works **everywhere**.

-------

If you are solving a math problem:


``` dart
final random = XrandomHq();  // works on mobile and desktop

for (var i=0; i<BILLIONS; i++)
    feedMonteCarloSimulation( random.nextDouble() );
```

**`XrandomHq`** class is uncompromisingly  **high quality** and works on **64-bit platforms**: i.e. on all desktops, phones and tablets.

But if your target is JavaScript (Flutter Web, Node.js):

``` dart
final random = XrandomJq();  // works on all platforms

for (var i=0; i<BILLIONS; i++)  
    feedMonteCarloSimulation( random.nextDouble() ); // on JS? O_O  
```

**`XrandomJq`** class is **high quality**, and works **everywhere**.


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
|    | Xorshift64             |        577 |       358 |
| ✓  | Xrandom                |        628 |       228 |
|    | Xorshift128p           |        629 |       395 |
|    | Splitmix64             |        667 |       397 |
| ✓  | Xorshift128            |        823 |       347 |
| ✓  | **Random (dart:math)** |        929 |           |
|    | XrandomHq              |       1154 |       712 |
| ✓  | XrandomJq              |       1204 |       536 |


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
| ✓  | Xrandom                |     628 |       222 |       535 |
| ✓  | Xorshift128            |     722 |       334 |       778 |
|    | Xorshift64             |     749 |       353 |       509 |
|    | Xorshift128p           |     766 |       387 |       532 |
|    | Splitmix64             |     836 |       403 |       503 |
| ✓  | **Random (dart:math)** |     878 |           |           |
| ✓  | XrandomJq              |     926 |       532 |      1191 |
|    | XrandomHq              |    1120 |       724 |      1070 |

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
| ✓  | `Xoshiro128pp` | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) |  2019 | `XrandomJq` |
|    | `Xoshiro256pp` | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) |  2019 | `XrandomHq` |
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
| ✓  | Xrandom                |     628 |        628 |      407 |
| ✓  | Xorshift128            |     722 |        823 |      409 |
|    | Xorshift64             |     749 |        577 |      386 |
|    | Xorshift128p           |     766 |        629 |      391 |
|    | Splitmix64             |     836 |        667 |      385 |
| ✓  | **Random (dart:math)** |     878 |        929 |      661 |
| ✓  | XrandomJq              |     926 |       1204 |      414 |
|    | XrandomHq              |    1120 |       1154 |      394 |




All the benchmarks on this page are from AOT-compiled binaries running on AMD A9-9420e with Ubuntu 20.04. Time is measured in milliseconds.

# Consistency

The library has been thoroughly **tested to match reference numbers** generated by C algorithms. The
sources in C are taken directly from scientific publications or the reference implementations by the authors of the algorithms. The Xorshift128+ results are also matched to reference
values from [JavaScript xorshift library](https://github.com/AndreasMadsen/xorshift), which tested
the 128+ similarly.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu**, and **macOS** in **VM** and **Node.js** modes.


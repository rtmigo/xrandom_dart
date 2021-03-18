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
| Random (dart:math)     |  1172   |    1541    |   1134   |
| Xrandom             |   719   |    1126    |   710    |



# Which to choose

If you just want a random number:

``` dart
final random = Xrandom();  // works on all platforms

quoteOfTheDay = quotes[ random.nextInt(quotes.length) ];
``` 

**`Xrandom`** class is **fast** and works **everywhere**.

-------

If you need billions and billions of randoms without statistical artifacts:


``` dart
final random = XrandomHq();  // works on mobile and desktop

for (var i=0; i<BILLIONS; i++)
    feedMonteCarloSimulation( random.nextDouble() );
```

**`XrandomHq`** class is **high quality** and works on  
**64-bit platforms**. That is, on desktops, phones and tablets.

-------

If you compile your code to JavaScript (Flutter Web, Node.js) and still want something more serious, than simple `Xrandom`:

``` dart
final random = XrandomJs();  // works on all platforms

for (var i=0; i<BILLIONS; i++)  
    feedMonteCarloSimulation( random.nextDouble() ); // on JS? O_O  
```

**`XrandomJs`** class is **high quality** with compromises, and works **everywhere**.


# Additions to Random


## nextFloat

`nextFloat` generates a floating-point value in range 0.0≤x<1.0.

Unlike the `nextDouble`, `nextFloat` prefers speed to precision. 
It's still a `double` that has four billion shades, but generated faster.

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


## nextRaw

These methods return the raw output of the generator uncompromisingly fast. Depending on the algorithm, 
the output is a number consisting of either 32 random bits or 64 random bits. 

Xrandom concatenates 32-bit sequences into 64-bit and vice versa. Therefore, both methods work regardless of the algorithm.


| JS    | Method        | Returns         | Equivalent of                   | 
|-------|--------|-----------------|---------------------------------|
| ✓ | `nextRaw32()` | 32-bit unsigned | `nextInt(0xffffffff)+1`         |
|   | `nextRaw64()` | 64-bit signed   | `nextInt(0xffffffffffffffff)+1` |


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

| JS    | Class  | Algorithm  |    Published | Alias |
|-------|--------|------------|-------------------|------|
| ✓ | `Xorshift32` |   [xorshift32](https://www.jstatsoft.org/article/view/v008i14)   | 2003 | `Xrandom` |
|  | `Xorshift64`      | [xorshift64](https://www.jstatsoft.org/article/view/v008i14)   |  2003 |
| ✓ | `Xorshift128`     | [xorshift128](https://www.jstatsoft.org/article/view/v008i14)  |  2003 |
|  | `Xorshift128p` | [xorshift128+ v2](https://arxiv.org/abs/1404.0390) |  2015 |
| ✓ | `Xoshiro128pp` | [xoshiro128++ 1.0](https://prng.di.unimi.it/xoshiro128plusplus.c) |  2019 | `XrandomJs` |
|   | `Xoshiro256pp` | [xoshiro256++ 1.0](https://prng.di.unimi.it/xoshiro256plusplus.c) |  2019 | `XrandomHq` |
|  | `Splitmix64` | [splitmix64](https://prng.di.unimi.it/splitmix64.c) |  2015 |

# Compatibility

You can safely **use any classes on mobile and desktop** platforms. 

But if you target **JavaScript** (Web, Node.js), you will have to 
**limit your choice**. The reason is the lack of support for 64-bit numbers 
in JavaScript.



Trying to create a JavaScript-incompatible object in JavaScripts-compiled will lead to `UnsupportedError`.




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
sources in C are taken directly from scientific publications or the reference implementations by the authors of the algorithms. The Xorshift128+ results are also matched to reference
values from [JavaScript xorshift library](https://github.com/AndreasMadsen/xorshift), which tested
the 128+ similarly.

Testing is done in the GitHub Actions cloud on **Windows**, **Ubuntu**, and **macOS** in **VM** and **Node.js** modes.


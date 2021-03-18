// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

import 'package:cli/nullsafe_tabulate.dart';
import 'package:xrandom/xrandom.dart';



enum DoWhat { nextDouble, nextInt, nextBool, nextInt32, nextInt64, nextFloat,  }

const NUM_EXPERIMENTS = 3;
const NUM_ITEMS_PER_EXPERIMENT = 1000000;

int measureTimeRuns = 0;

int measureTime(Random r, DoWhat dbl) {
  print('${++measureTimeRuns} benchmarking ${r.runtimeType} $dbl');

  final nextIntMax = Random().nextInt(0xFFFFFFFF)+1;

  final sw = Stopwatch()..start();

  const N = NUM_ITEMS_PER_EXPERIMENT;

  switch (dbl) {
    case DoWhat.nextDouble:
      for (var i = 0; i < N; ++i) r.nextDouble();
      break;
    case DoWhat.nextBool:
      for (var i = 0; i < N; ++i) r.nextBool();
      break;
    case DoWhat.nextInt:
      for (var i = 0; i < N; ++i) { r.nextInt(nextIntMax); }
      break;
    case DoWhat.nextInt32:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i)
          r.nextRaw32();
      }
      break;
    case DoWhat.nextInt64:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i) r.nextRaw64();
      }
      break;
    case DoWhat.nextFloat:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i) r.nextFloat();
      }
      break;
    // case DoWhat.nextFloatInline:
    //   if (r is RandomBase32) {
    //     for (var i = 0; i < N; ++i) r.nextFloatInline();
    //   }
    //   break;
    // case DoWhat.nextFloatUint:
    //   if (r is RandomBase32) {
    //     for (var i = 0; i < N; ++i) r.nextFloatUint();
    //   }
    //   break;

  }

  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) =>
    (values.reduce((a, b) => a + b) / values.length).round();

class Bench implements Comparable {
  Bench(this.className, this.doWhat);

  final String className;
  final DoWhat doWhat;
  final results = <int>[];

  @override
  String toString() {
    return className + doWhat.toString();
  }

  @override
  int compareTo(other) => toString().compareTo(other.toString());
}

//List<T> shuffled(List<T> a) {
//a.s
//}

void main(List<String> arguments) {
  final results = <String, Map<DoWhat, List<int>>>{};

  // git stash && git pull origin master && dart pub get && ./run.sh

  final dowhatz = [
    DoWhat.nextInt,
    DoWhat.nextDouble,
    DoWhat.nextBool,
    DoWhat.nextInt32,
    DoWhat.nextInt64,
    DoWhat.nextFloat,
    DoWhat.nextFloat,
    // DoWhat.nextFloatUint,
    // DoWhat.nextFloatInline,
  ];

  List<Random> listGenerators() => [
        Random(777),
        Xorshift32.expected(),
        Xorshift64.expected(),
        Xorshift128.expected(),
        Xorshift128p.expected(),
        Xoshiro128pp.expected(),
        Xoshiro256pp.expected(),
        Splitmix64.expected(),
      ];

  for (var experiment = 0; experiment < NUM_EXPERIMENTS; ++experiment) {
    for (final doingWhat in dowhatz) {
      for (var random in listGenerators()..shuffle()) {
        final time = measureTime(random, doingWhat);
        results
            .putIfAbsent(
                random.runtimeType.toString(), () => <DoWhat, List<int>>{})
            .putIfAbsent(doingWhat, () => <int>[])
            .add(time);
      }
    }
  }

  void printColumns(List<DoWhat> whatz) {
    final rows = <List<dynamic>>[];

    final header = ['JS', 'Time (lower is better)'];
    for (final x in whatz) {
      final str = x.toString();
      header.add(str.substring(str.lastIndexOf('.') + 1));
    }

    rows.add(header);

    final otherRows = <List<dynamic>>[];

    for (final random in listGenerators()) {
      final row = <dynamic>[];

      //if (random is RandomBase32)
        row.add(( (random is RandomBase64) | !(random is RandomBase32) ) ? '+' : '-' );

      otherRows.add(row);

      final type = random.runtimeType.toString();
      row.add(type == '_Random' ? 'Random (dart:math)' : type);

      for (final doWhat in whatz) {
        final times = results[type]![doWhat]!;
        final avg = mean(times);
        row.add(avg == 0 ? 0 : avg);
      }
    }

    rows.addAll(otherRows);

//    print('To be out not to be? ${random.nextBool() ? "yes" : "no"}');

    print(tabulate(rows, sorting: [Sort(2)], markdownAlign: true));
  }

  print('');

  printColumns([DoWhat.nextInt, DoWhat.nextDouble, DoWhat.nextBool]);

  print('');

  // printColumns([
  //   DoWhat.nextFloat,
  //   DoWhat.nextFloatUint,
  //   DoWhat.nextFloatInline,
  // ]);


  printColumns([
    DoWhat.nextInt,
    DoWhat.nextInt32,
    DoWhat.nextInt64,
  ]);

  print('');

  printColumns([
    DoWhat.nextDouble,
    DoWhat.nextFloat,
  ]);

  print('');
}

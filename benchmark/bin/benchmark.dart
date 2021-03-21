// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

import 'package:cli/nullsafe_tabulate.dart';
import 'package:xrandom/xrandom.dart';


enum DoWhat { nextDouble, nextInt, nextBool, nextRaw32, nextRaw64, nextFloat,  }

const NUM_EXPERIMENTS = 50;
const NUM_ITEMS_PER_EXPERIMENT = 1000000;

int measureTimeRuns = 0;

int measureTime(Random r, DoWhat dbl) {
  //print('${++measureTimeRuns} benchmarking ${r.runtimeType} $dbl');

  final nextIntMax = Random().nextInt(0xFFFFFFFF)+1;

  final sw = Stopwatch()..start();

  //bool is32 = (r is Xorshift128p);

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
    case DoWhat.nextRaw32:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i)
          r.nextRaw32();
      }
      break;
    case DoWhat.nextRaw64:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i) r.nextRaw64();
      }
      break;
    case DoWhat.nextFloat:
      if (r is RandomBase32) {
        for (var i = 0; i < N; ++i) r.nextFloat();
      }
      break;
  }

  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) =>
    (values.reduce((a, b) => a + b)*30 / values.length).round();

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
    DoWhat.nextRaw32,
    DoWhat.nextRaw64,
    DoWhat.nextFloat,
    // DoWhat.nextFloat,
    // DoWhat.nextFloatUint,
    // DoWhat.nextFloatInline,
  ];

  List<Random> listGenerators() => [
        Random(777),
        Xorshift32.seeded(),
        Xorshift64.seeded(),
        Xorshift128.seeded(),
        Xorshift128p.seeded(),
        Xoshiro128pp.seeded(),
        Xoshiro256pp.seeded(),
        Splitmix64.seeded(),
        Mulberry32.seeded(),
      ];

  for (var experiment = 0; experiment < NUM_EXPERIMENTS; ++experiment) {
    print('Experiment ${experiment+1}/$NUM_EXPERIMENTS');
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

    final header = ['JS', 'Class'];
    for (final x in whatz) {
      final str = x.toString();
      header.add(str.substring(str.lastIndexOf('.') + 1));
    }

    rows.add(header);

    final otherRows = <List<dynamic>>[];

    for (final random in listGenerators()) {
      final row = <dynamic>[];

      var jsSupported = true;
      if (random is RandomBase64 || random is Mulberry32) {
        jsSupported = false;
      }

      //if (random is RandomBase32)
        row.add( jsSupported ? '✓' : '' );

      otherRows.add(row);

      var typekey = random.runtimeType.toString();
      var typestr = typekey;
      //bool emphasize = false;
      if (typestr == '_Random') {
        typestr = '**Random (dart:math)**';
        //emphasize = true;
      } else if (typestr == 'Xorshift32') {
        typestr = 'Xrandom';
      // } else if (typestr == 'Xoshiro256pp') {
      //   typestr = 'XrandomHq';
      } else if (typestr == 'Xoshiro128pp') {
        typestr = 'Qrandom / Drandom';
      }
      row.add(typestr);

      for (final doWhat in whatz) {
        final times = results[typekey]![doWhat]!;
        final avg = mean(times);
        row.add(avg == 0 ? 0 : avg);
      }
    }

    rows.addAll(otherRows);

//    print('To be out not to be? ${random.nextBool() ? "yes" : "no"}');

    print(tabulate(rows, sorting: [Sort(2)], markdownAlign: true));
  }

  print('');
//
  printColumns([DoWhat.nextInt, DoWhat.nextDouble, DoWhat.nextBool]);

  //printColumns([DoWhat.nextInt]);


  print('');


  printColumns([
    DoWhat.nextInt,
    DoWhat.nextRaw32,
    DoWhat.nextRaw64,
  ]);

  print('');

  printColumns([
    DoWhat.nextDouble,
    DoWhat.nextFloat,
  ]);

  print('');
}

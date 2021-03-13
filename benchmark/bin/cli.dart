import 'dart:math';

import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

enum DoWhat {
  nextDouble,
  nextInt,
  nextBool
}

int measureTime(Random r, DoWhat dbl)
{
  print('Bechmarking ${r.runtimeType}');

  final sw = Stopwatch()..start();

  for (var i = 0; i < 10000000; ++i) {
    switch (dbl)
    {
      case DoWhat.nextDouble:
        r.nextDouble();
        break;
      case DoWhat.nextBool:
        r.nextBool();
        break;
      case DoWhat.nextInt:
        r.nextInt(100);
        break;

    }
  }
  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) => (values.reduce((a, b) => a + b) / values.length).round();

void main(List<String> arguments) {

  final results = <String,List<int>>{};

  // git stash && git pull origin master && dart pub get && ./run.sh

  for (var i=0; i<2; ++i)
    {
      for (final what in [DoWhat.nextBool, DoWhat.nextInt, DoWhat.nextDouble])
      //for (var j=0; j<2; ++j)
        {
          //final doubles = j==0;
          print('== $i $what ==');
          //final suffix = doubles ? " double" : " bool";
          results.putIfAbsent('Random\t$what', () => <int>[]).add(measureTime(Random(777), what));
          results.putIfAbsent('Xorshift128Plus\t$what', () => <int>[]).add(measureTime(Xorshift128Plus.deterministic(), what));
          results.putIfAbsent('Xorshift32\t$what', () => <int>[]).add(measureTime(Xorshift32.deterministic(), what));
          results.putIfAbsent('Xorshift64\t$what', () => <int>[]).add(measureTime(Xorshift64.deterministic(), what));
          results.putIfAbsent('Xorshift128\t$what', () => <int>[]).add(measureTime(Xorshift128.deterministic(), what));
        }
    }


  for (final entry in results.entries)
    {
      print('${entry.key}\t${mean(entry.value)}');
    }

  //final r = Xorshift128Plus(1,2);
  //print('Hello $xxxx world: ${r.next()}!');
}

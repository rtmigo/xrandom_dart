import 'dart:math';

import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

int measureTime(Random r, bool dbl)
{
  print('Bechmarking ${r.runtimeType}');

  final sw = Stopwatch()..start();

  for (var i = 0; i < 100000000; ++i) {
    if (dbl)
      r.nextDouble();
    else
      r.nextBool();
  }
  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) => (values.reduce((a, b) => a + b) / values.length).round();

void main(List<String> arguments) {

  final results = <String,List<int>>{};

  for (var i=0; i<5; ++i)
    {
      for (var j=0; j<2; ++j)
        {
          final doubles = j==0;
          print('== $i double:$doubles ==');
          final suffix = doubles ? " double" : " bool"
          results.putIfAbsent('Random$suffix', () => <int>[]).add(measureTime(Random(777), doubles));
          results.putIfAbsent('Xorshift128Plus$suffix', () => <int>[]).add(measureTime(Xorshift128Plus.deterministic(), doubles));
          results.putIfAbsent('Xorshift32$suffix', () => <int>[]).add(measureTime(Xorshift32.deterministic(), doubles));
          results.putIfAbsent('Xorshift64$suffix', () => <int>[]).add(measureTime(Xorshift64.deterministic(), doubles));
          results.putIfAbsent('Xorshift128$suffix', () => <int>[]).add(measureTime(Xorshift128.deterministic(), doubles));
        }
    }


  for (final entry in results.entries)
    {
      print('${entry.key} ${mean(entry.value)}');
    }

  //final r = Xorshift128Plus(1,2);
  //print('Hello $xxxx world: ${r.next()}!');
}

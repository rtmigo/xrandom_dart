import 'dart:math';

import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

int measureTime(Random r)
{
  print('Bechmarking ${r.runtimeType}');

  final sw = Stopwatch()..start();

  for (var i = 0; i < 100000000; ++i) {
    r.nextBool();
  }
  return sw.elapsed.inMilliseconds;
}

int mean(List<int> values) => (values.reduce((a, b) => a + b) / values.length).round();

void main(List<String> arguments) {

  final results = <String,List<int>>{};

  for (var i=0; i<5; ++i)
    {
      print('== $i ==');
      results.putIfAbsent('Random', () => <int>[]).add(measureTime(Random(777)));
      results.putIfAbsent('Xorshift128Plus', () => <int>[]).add(measureTime(Xorshift128Plus.deterministic()));
      results.putIfAbsent('Xorshift32', () => <int>[]).add(measureTime(Xorshift32.deterministic()));
      results.putIfAbsent('Xorshift64', () => <int>[]).add(measureTime(Xorshift64.deterministic()));
      results.putIfAbsent('Xorshift128', () => <int>[]).add(measureTime(Xorshift128.deterministic()));
    }


  for (final entry in results.entries)
    {
      print('${entry.key} ${mean(entry.value)}');
    }

  //final r = Xorshift128Plus(1,2);
  //print('Hello $xxxx world: ${r.next()}!');
}

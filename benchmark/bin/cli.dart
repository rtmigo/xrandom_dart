import 'dart:math';

import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

int measureTime(Random r)
{
  final sw = Stopwatch()..start();

  for (var i = 0; i < 100000; ++i) {
    r.nextBool();
  }
  return sw.elapsed.inMilliseconds;
}

void main(List<String> arguments) {

  final results = <String,List<int>>{};

  results.putIfAbsent('128+', () => <int>[]).add(measureTime(Xorshift128Plus.deterministic()));

  for (final entry in results.entries)
    {
      print('{${entry.key} ${entry.value}');
    }

  //final r = Xorshift128Plus(1,2);
  //print('Hello $xxxx world: ${r.next()}!');
}

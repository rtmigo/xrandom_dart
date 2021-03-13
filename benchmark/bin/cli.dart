import 'dart:math';



import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

import 'nullsafe_tabulate.dart';

enum DoWhat {
  nextDouble,
  nextInt,
  nextBool
}

int measureTime(Random r, DoWhat dbl)
{
  print('Bechmarking ${r.runtimeType}');

  final sw = Stopwatch()..start();

  for (var i = 0; i < 1000000; ++i) {
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
  int compareTo(other) => this.toString().compareTo(other.toString());
}

void main(List<String> arguments) {

  final results = <String, Map<DoWhat,List<int>>> {};



  // git stash && git pull origin master && dart pub get && ./run.sh

  final dowhatz = [DoWhat.nextBool, DoWhat.nextInt, DoWhat.nextDouble];


  for (var experiment = 0; experiment < 2; ++experiment) {
    for (final doingWhat in dowhatz) {
      for (var random in [
          Random(777),
          Xorshift32.deterministic(),
          Xorshift64.deterministic(),
          Xorshift128.deterministic(),
          Xorshift128Plus.deterministic(),
        ]) {
        final time = measureTime(random, doingWhat);
          results.putIfAbsent(
              random.runtimeType.toString(),
              () => <DoWhat,List<int>>{})
            .putIfAbsent(doingWhat, () => <int>[])
            .add(time);
      }

      //
      // //for (var j=0; j<2; ++j)
      //   {
      //     //final doubles = j==0;
      //     print('== $experiment $doingWhat ==');
      //     //final suffix = doubles ? " double" : " bool";
      //
      //     var bench;
      //
      //     bench = Bench("Random", doingWhat);
      //     results.putIfAbsent(bench, () => bench).add(value)
      //
      //     results.putIfAbsent('Random\t$doingWhat', () => <int>[]).add(measureTime(Random(777), doingWhat));
      //     results.putIfAbsent('Xorshift128Plus\t$doingWhat', () => <int>[]).add(measureTime(Xorshift128Plus.deterministic(), doingWhat));
      //     results.putIfAbsent('Xorshift32\t$doingWhat', () => <int>[]).add(measureTime(Xorshift32.deterministic(), doingWhat));
      //     results.putIfAbsent('Xorshift64\t$doingWhat', () => <int>[]).add(measureTime(Xorshift64.deterministic(), doingWhat));
      //     results.putIfAbsent('Xorshift128\t$doingWhat', () => <int>[]).add(measureTime(Xorshift128.deterministic(), doingWhat));
      //   }
    }
  }

  final rows = <List<String>>[];

  final header = ['Class'];
  for (final x in dowhatz) {
    final str = x.toString();
    header.add(str.substring(str.lastIndexOf('.')+1));
  }

  rows.add(header);


  //rows.add("value")

  for (final type in results.keys)
    {
      final row = [type];
      rows.add(row);
      for (final dowhat in dowhatz) {
        final times = results[type]![dowhat]!;
        final avg = mean(times);

        row.add(avg.toString());

        //print("$type $dowhat $avg");
      }
      //for (final results in typeToDowhat.value[type]) {

        //DoWhat what = whatToResults.
      //}

      //print('${entry.key}\t${mean(entry.value)}');
    }

  print(tabulate(rows));

  //for (var r in rows)
    //print(r);

  //final r = Xorshift128Plus(1,2);
  //print('Hello $xxxx world: ${r.next()}!');
}

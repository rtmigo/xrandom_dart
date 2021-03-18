import 'package:xrandom/xrandom.dart';

void main() {
  final xrandom = Xrandom();

  print('Random number: ${xrandom.nextInt(100)}');

  var shuffledList = [1, 2, 3, 4, 5]..shuffle(xrandom);
  print('Shuffled list: $shuffledList');

  int raw = xrandom.nextRaw32();
  print('Raw generator output: ${raw.toRadixString(16)}');
}

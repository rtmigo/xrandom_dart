import 'dart:math';

abstract class UniRandom implements Random {

  int next();

  @override
  bool nextBool() {
    // TODO: implement nextBool
    throw UnimplementedError();
  }

  @override
  double nextDouble() {
    // TODO: implement nextDouble
    throw UnimplementedError();
  }

  @override
  int nextInt(int max) {
    // TODO: implement nextInt
    throw UnimplementedError();
  }
}
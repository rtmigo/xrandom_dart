import 'package:cli/cli.dart' as cli;
import 'package:xorshift/xorshift.dart';

void main(List<String> arguments) {
  final r = Xorshift();
  print('Hello world: ${r.next()}!');
}

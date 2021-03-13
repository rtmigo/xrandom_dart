// https://github.com/BLeAm/tabulate/blob/master/lib/tabulate.dart
// MIT License
// Copyright (c) 2019 BLeAmz

// rewriting (from scratch?)

String tabulate(List<List<String>> rows, List<String> header) {

  String retString = '';

  header = rows[0];

  final columnsCount = header.length;
  final colWidth = List<int>.filled(columnsCount, 0);
  
  
  
  if (rows.any((model) => model.length != columnsCount)) {
    throw Exception('Column\'s no. of each model does not match.');
  }

  //preparing colLength.
  for (var i = 0; i < columnsCount; i++) {
    final _chunk = <String>[];
    for (final model in rows) {
      _chunk.add(model[i]);
    }
    colWidth[i] = ([for (var c in _chunk) c.length]..sort()).last; // max ?
  }
  // here we got prepared colLength.

  String fillSpace(int maxSpace, String text) {
    return text.padLeft(maxSpace) + ' | ';
  }

  void addRow(List<String> model, List<List<String>> row) {
    final l = <String>[];
    for (var i = 0; i < columnsCount; i++) {
      int max = colWidth[i];
      l.add(fillSpace(max, model[i]));
    }
    row.add(l);
  }

  List<List<String>> rowList = [];
  addRow(header, rowList);
  List<String> topBar = List.generate(columnsCount, (i) => '-' * colWidth[i]);
  addRow(topBar, rowList);
  rows.forEach((model) => addRow(model, rowList));
  rowList.forEach((row) {
    var rowText = row.join();
    rowText = rowText.substring(0, rowText.length - 2);
    retString += rowText + '\n';
  });

  return retString;
}
// https://github.com/BLeAm/tabulate/blob/master/lib/tabulate.dart
// MIT License
// Copyright (c) 2019 BLeAmz

String tabulate(List<List<String>> models, List<String> header) {
  String retString = '';
  int cols = header.length;
  List<int> colLength = List.filled(cols, 0);
  if (models.any((model) => model.length != cols)) {
    throw Exception('Column\'s no. of each model does not match.');
  }

  //preparing colLength.
  for (int i = 0; i < cols; i++) {
    List<String> _chunk = [];
    _chunk.add(header[i]);
    for (var model in models) {
      _chunk.add(model[i]);
    }
    colLength[i] = ([for (var c in _chunk) c.length]..sort()).last;
  }
  // here we got prepared colLength.

  String fillSpace(int maxSpace, String text) {
    return text.padLeft(maxSpace) + ' | ';
  }

  void addRow(List<String> model, List<List<String>> row) {
    List<String> l = [];
    for (var i = 0; i < cols; i++) {
      int max = colLength[i];
      l.add(fillSpace(max, model[i]));
    }
    row.add(l);
  }

  List<List<String>> rowList = [];
  addRow(header, rowList);
  List<String> topBar = List.generate(cols, (i) => '-' * colLength[i]);
  addRow(topBar, rowList);
  models.forEach((model) => addRow(model, rowList));
  rowList.forEach((row) {
    var rowText = row.join();
    rowText = rowText.substring(0, rowText.length - 2);
    retString += rowText + '\n';
  });

  return retString;
}
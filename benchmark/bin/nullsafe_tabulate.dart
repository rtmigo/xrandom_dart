

import 'dart:math';

int maxCellLength(List<String> row) => row.map((cell)=>cell.length).reduce(max);

// String fillSpace(int maxSpace, String text) {
//   return text.padLeft(maxSpace) + ' | ';
// }

String alignCenter(String text, int targetWidth) {
  final half = (targetWidth-text.length)>>1;
  text = text.padLeft(text.length+half);
  text = text.padRight(targetWidth);
  return text;
}

String tabulate(List<List<String>> rows) {

  //String retString = '';

  //header = rows[0];

  final columnsCount = rows.map((r) => r.length).reduce(max);

  print('columnsCount $columnsCount');

  for (final row in rows) {
    while (row.length < columnsCount) {
      row.add('');
    }
  }

  print('POINT B');

  final columnsWidths = <int>[];
  for (var iCol=0; iCol<columnsCount; iCol++) {
    columnsWidths.add(
      rows.map((row) => row[iCol]).map((cell) => cell.length).reduce(max)
    );
  }

  print('POINT C');

  final formattedRows = <String>[];

  for (var row in rows) {
    var formatted = '|';
    var iCol = 0;
    for (final cell in row) {
      formatted += ' ';
      formatted += alignCenter(cell, columnsWidths[iCol++]);
      formatted += ' |';
    }
    formattedRows.add(formatted);
  }

  return formattedRows.join('\n');



  // https://github.com/BLeAm/tabulate/blob/master/lib/tabulate.dart
  // MIT License
  // Copyright (c) 2019 BLeAmz

  // rewriting (from scratch?)
  //
  // if (rows.any((model) => model.length != columnsCount)) {
  //   throw Exception('Column\'s no. of each model does not match.');
  // }
  //
  // //preparing colLength.
  // for (var i = 0; i < columnsCount; i++) {
  //   final _chunk = <String>[];
  //
  //   int rowNum = 0;
  //   for (final row in rows) {
  //     rowNum++;
  //     if (row.length!=header.length)
  //       throw ArgumentError("$rowNum ja");
  //     _chunk.add(row[i]);
  //   }
  //   colWidth[i] = ([for (var c in _chunk) c.length]..sort()).last; // max ?
  // }
  // // here we got prepared colLength.
  //
  // String fillSpace(int maxSpace, String text) {
  //   return text.padLeft(maxSpace) + ' | ';
  // }
  //
  // void addRow(List<String> model, List<List<String>> row) {
  //   final l = <String>[];
  //   for (var i = 0; i < columnsCount; i++) {
  //     int max = colWidth[i];
  //     l.add(fillSpace(max, model[i]));
  //   }
  //   row.add(l);
  // }
  //
  // List<List<String>> rowList = [];
  // addRow(header, rowList);
  // List<String> topBar = List.generate(columnsCount, (i) => '-' * colWidth[i]);
  // addRow(topBar, rowList);
  // rows.forEach((model) => addRow(model, rowList));
  // rowList.forEach((row) {
  //   var rowText = row.join();
  //   rowText = rowText.substring(0, rowText.length - 2);
  //   retString += rowText + '\n';
  // });
  //
  // return retString;
}
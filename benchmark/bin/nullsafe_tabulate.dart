// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: BSD-3-Clause


import 'dart:math';

enum Align {
  left,
  right,
  center
}

int maxCellLength(List<String> row) => row.map((cell)=>cell.length).reduce(max);

String alignCell(String text, int targetWidth, Align align)
{
  switch (align) {
    case Align.left:
      return text.padRight(targetWidth);
    case Align.right:
      return text.padLeft(targetWidth);
    case Align.center:
      return alignCenter(text, targetWidth);
  }
}

String alignCenter(String text, int targetWidth) {
  final half = (targetWidth-text.length)>>1;
  text = text.padLeft(text.length+half);
  text = text.padRight(targetWidth);
  return text;
}

String tabulate(List<List<String>> rows, {List<Align>? headerAlign, List<Align>? rowAlign}) {

  final columnsCount = rows.map((r) => r.length).reduce(max);

  for (final row in rows) {
    while (row.length < columnsCount) {
      row.add('');
    }
  }

  final columnsWidths = <int>[];
  for (var iCol=0; iCol<columnsCount; iCol++) {
    columnsWidths.add(
      rows.map((row) => row[iCol]).map((cell) => cell.length).reduce(max)
    );
  }

  var bar = List.generate(columnsCount, (i) => '-' * (columnsWidths[i]+2)).join('|');
  bar = '|'+bar+'|';

  final formattedRows = <String>[];

  var iRow = -1;
  for (var row in rows) {
    iRow++;

    if (iRow==1) {
      formattedRows.add(bar);
    }

    var formatted = '|';
    var iCol = -1;

    for (final cell in row) {
      formatted += ' ';
      iCol++;

      var align = Align.center;
      if (iRow == 0) {
        // header
        if (headerAlign != null && headerAlign.length > iCol) {
          align = headerAlign[iCol];
        }
      }
      else {
        // not header
        if (rowAlign != null && rowAlign.length > iCol) {
          align = rowAlign[iCol];
        }
      }

      formatted += alignCell(cell, columnsWidths[iCol], align);
      formatted += ' |';
    }
    formattedRows.add(formatted);
  }

  return formattedRows.join('\n');
}
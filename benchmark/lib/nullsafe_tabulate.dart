// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

import 'dart:math';

enum Align { left, right, center }

int maxCellLength(List<String> row) => row.map((cell) => cell.length).reduce(max);

String alignCell(String text, int targetWidth, Align align) {
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
  final half = (targetWidth - text.length) >> 1;
  text = text.padLeft(text.length + half);
  text = text.padRight(targetWidth);
  return text;
}

String cellToString(dynamic cell) => cell.toString();

/// @param rowsOnly Rows to be sorted (without the header).
/// @param columnIndexes Determines the sorting order. `[2,-3,1]` means, that rows must
/// be sorted by column 2 ascending, or -3 descending, or 1 ascending.
void sortRo(List<List<dynamic>> rowsOnly, List<int> columnIndexes1based) {
  rowsOnly.sort((row1, row2) {
    for (final colIndex1based in columnIndexes1based) {
      if (colIndex1based == 0) {
        throw ArgumentError.value(colIndex1based, 'colIndex');
      }

      var idx = colIndex1based.abs() - 1;
      var cell1 = row1[idx];
      var cell2 = row2[idx];

      //print('Comparing $cell1 $cell2');

      if (cell1 == cell2) {
        //print('Go next');
        continue;
      }

      if (cell1 > cell2) {
        //print('Ret ${colIndex1based.sign}');
        return colIndex1based.sign;
      }
      return -colIndex1based.sign;
    }
    ;
    return 0;
  });
}

void sortFull(List<List<dynamic>> rows, List<int> columnIndexes) {
  final allExceptHeader = rows.skip(1).toList();
  sortRo(allExceptHeader, columnIndexes);
  rows.length = 1;
  rows.addAll(allExceptHeader);
}

Align guessAlignCell(dynamic cell) {
  return (cell is num) ? Align.right : Align.left;
}

Align guessAlignColumn(Iterable<dynamic> allCellsInColumn) {
  Align? result;

  for (final cell in allCellsInColumn) {
    if (result == null) {
      result = guessAlignCell(cell);
    } else if (guessAlignCell(cell) != result) {
      return Align.left; // default
    }
  }

  result ??= Align.left;
  return result;
}

Iterable<dynamic> enumerateColumn(List<List<dynamic>> rows, int colIndex) sync* {
  for (final row in rows) {
    yield row[colIndex];
  }
}

List<List<dynamic>> copyRows(List<List<dynamic>> rows) {

  return rows.map((e) => e.toList()).toList();

  // final result = <List<dynamic>>[];
  // for (final row in rows) {
  //   result.add(row.toList());
  // }
  // return result;
}

// enum Order {
//   ascending,
//   descending
// }

class Sort {
  Sort(this.column, [this.ascending = true]);

  dynamic column;
  bool ascending;
}

String generateBar(int width, Align? align) {
  switch (align) {
    case null:
    case Align.left:
      return '-' * (width + 2);
    case Align.right:
      return '-' * (width + 1) + ':';
    case Align.center:
      return ':' + '-' * width + ':';
  }
}

/// @param sorting Determines the sorting order.
String tabulate(List<List<dynamic>> rows,
    {List<Align>? headerAlign, List<Align>? rowAlign, List<Sort>? sorting, markdownAlign = false}) {
  final headerRow = rows[0].map((e) => cellToString(e)).toList(growable: false);

  rows = copyRows(rows);

  int toColIndex(dynamic col) {
    if (col is int) {
      return col;
    }
    final idx = headerRow.indexOf(col.toString());
    if (idx < 0) {
      throw ArgumentError.value(col, 'col', 'Column not found.');
    }
    return idx;
  }

  if (sorting != null) {
    final headerRow = rows[0].map((e) => cellToString(e)).toList(growable: false);
    final sortingIndexes = <int>[]; // 1-based
    for (var item in sorting) {
      var idx = toColIndex(item.column) + 1;
      //var srt = pair[1] as Order;

      if (!item.ascending) {
        idx = -idx;
      }
      sortingIndexes.add(idx);
      // if (item is int) {
      //   if (item==0) {
      //     throw ArgumentError.value(sorting, 'Indices are counted from one.');
      //   }
      //   sortingIndexes.add(item);
      // } else {
      //   final itemStr = item.toString();
      //   final idx = headerRow.indexOf(itemStr);
      //   if (idx < 0) {
      //     throw ArgumentError.value(sorting, 'Column "$itemStr" not found.');
      //   }
      //   sortingIndexes.add(idx+1);
      // }
    }
    sortFull(rows, sortingIndexes);
  }

  //  sortFull(rows, sorting);
  //}

  final columnsCount = rows.map((r) => r.length).reduce(max);

  for (final row in rows) {
    while (row.length < columnsCount) {
      row.add('');
    }
  }

  rowAlign ??= <Align>[];
  for (var iCol = 0; iCol < columnsCount; iCol++) {
    if (rowAlign.length <= iCol) {
      rowAlign.add(guessAlignColumn(enumerateColumn(rows, iCol).skip(1)));
      assert(!(rowAlign.length <= iCol));
    }
  }
  //rowAlign = <Align>[];

  final columnsWidths = <int>[];
  for (var iCol = 0; iCol < columnsCount; iCol++) {
    columnsWidths
        .add(rows.map((row) => row[iCol]).map((cell) => cellToString(cell).length).reduce(max));
  }

  var bar = List.generate(
          columnsCount, (i) => generateBar(columnsWidths[i], markdownAlign ? rowAlign![i] : null))
      .join('|');
  bar = '|' + bar + '|';

  final formattedRows = <String>[];

  var iRow = -1;
  for (var row in rows) {
    iRow++;

    if (iRow == 1) {
      formattedRows.add(bar);
    }

    var formatted = '|';
    var iCol = -1;

    for (final cell in row) {
      formatted += ' ';
      iCol++;

      var align = (cell is num) ? Align.right : Align.left;
      if (iRow == 0) {
        // header
        if (headerAlign != null && headerAlign.length > iCol) {
          align = headerAlign[iCol];
        }
      } else {
        // not header
        if (rowAlign != null && rowAlign.length > iCol) {
          align = rowAlign[iCol];
        }
      }

      formatted += alignCell(cellToString(cell), columnsWidths[iCol], align);
      formatted += ' |';
    }
    formattedRows.add(formatted);
  }

  return formattedRows.join('\n');
}

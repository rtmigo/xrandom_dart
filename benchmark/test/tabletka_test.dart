// SPDX-FileCopyrightText: (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

//**import 'package:cli/benchmark.dart';
import 'package:cli/nullsafe_tabulate.dart';
import 'package:test/test.dart';

String mini(String s) {
  final strippedRows = s.split('\n').map((s) => s.trim()).toList();
  while (strippedRows.isNotEmpty && strippedRows.first.isEmpty) {
    strippedRows.removeAt(0);
  }

  while (strippedRows.isNotEmpty && strippedRows.last.isEmpty) {
    strippedRows.removeLast();
  }

  return strippedRows.join('\n');
}

void main() {
  final months = [
    ['Winter', 'Spring', 'Summer', 'Autumn'],
    ['December', 'March', 'June', 'September'],
    ['January', 'April', 'July', 'October'],
    ['February', 'May', 'August', 'November']
  ];

  final numbers = [
    ['First', 'Second', 'Third'],
    [85, 10, 27],
    [512, 2348, 12037],
    [5, 10, 3],
    [512, -1, 037],
    [1, 10, 100],
  ];

  test('strings', () {
    var t = tabulate([
      ['Winter', 'Spring', 'Summer', 'Autumn'],
      ['December', 'March', 'June', 'September'],
      ['January', 'April', 'July', 'October'],
      ['February', 'May', 'August', 'November']
    ]);

    expect(t, mini(''' 
          | Winter   | Spring | Summer | Autumn    |
          |----------|--------|--------|-----------|
          | December | March  | June   | September |
          | January  | April  | July   | October   |
          | February | May    | August | November  |
        '''));
  });

  test('markdown align by guess', () {
    var t = tabulate(numbers, markdownAlign: true);
    print(t);

    expect(t, mini('''
          | First | Second | Third |
          |------:|-------:|------:|
          |    85 |     10 |    27 |
          |   512 |   2348 | 12037 |
          |     5 |     10 |     3 |
          |   512 |     -1 |    37 |
          |     1 |     10 |   100 |
        '''));
  });

  test('digits', () {
    var t = tabulate([
      ['First', 'Second', 'Third'],
      [85, 2, 27],
      [1414, 2348, 12037],
      [114, 248, 037],
      [1, 2, 3],
    ]);

    expect(t, mini(''' 
          | First | Second | Third |
          |-------|--------|-------|
          |    85 |      2 |    27 |
          |  1414 |   2348 | 12037 |
          |   114 |    248 |    37 |
          |     1 |      2 |     3 |
        '''));
  });

  group('sorting numbers', () {
    test('by single index', () {
      final t = tabulate(numbers, sorting: [Sort(1)]);
      //print(t);
      expect(t, mini(''' 
        | First | Second | Third |
        |-------|--------|-------|
        |   512 |     -1 |    37 |
        |    85 |     10 |    27 |
        |     5 |     10 |     3 |
        |     1 |     10 |   100 |
        |   512 |   2348 | 12037 |
        '''));
    });

    test('by indices [1, 0] [asc, asc]', () {
      final t = tabulate(numbers, sorting: [Sort(1, true), Sort(0, true)]);
      //print(t);
      expect(t, mini('''
        | First | Second | Third |
        |-------|--------|-------|
        |   512 |     -1 |    37 |
        |     1 |     10 |   100 |
        |     5 |     10 |     3 |
        |    85 |     10 |    27 |
        |   512 |   2348 | 12037 |
        '''));
    });

    test('by indices [0, 1] [asc, asc]', () {
      final t = tabulate(numbers, sorting: [Sort(0, true), Sort(1, true)]);
      //print(t);
      expect(t, mini('''
        | First | Second | Third |
        |-------|--------|-------|
        |     1 |     10 |   100 |
        |     5 |     10 |     3 |
        |    85 |     10 |    27 |
        |   512 |     -1 |    37 |
        |   512 |   2348 | 12037 |
        '''));
    });

    test('by two indices, asc-desc', () {
      final t = tabulate(numbers, sorting: [Sort(1, false), Sort(0, true)]);
      expect(t, mini('''
        | First | Second | Third |
        |-------|--------|-------|
        |   512 |   2348 | 12037 |
        |     1 |     10 |   100 |
        |     5 |     10 |     3 |
        |    85 |     10 |    27 |
        |   512 |     -1 |    37 |
        '''));
    });

    test('by name, asc-desc', () {
      final t = tabulate(numbers, sorting: [Sort('Second', false), Sort('First', true)]);
      //print(t);
      expect(t, mini('''
        | First | Second | Third |
        |-------|--------|-------|
        |   512 |   2348 | 12037 |
        |     1 |     10 |   100 |
        |     5 |     10 |     3 |
        |    85 |     10 |    27 |
        |   512 |     -1 |    37 |
        '''));
    });
  });
}

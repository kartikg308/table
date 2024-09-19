// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dynamic_table/models/cell_model.dart';

class TableModel {
  List<List<Cell>> cells;
  List<double> columnWidths;
  List<double> rowHeights;
  int numRows;
  int numCols;
  double defaultCellWidth;
  double defaultCellHeight;
  bool showResizeHandlers;
  Map<String, int> tableSize;
  int? selectedRow;
  int? selectedColumn;
  Offset tablePosition;
  double tableWidth;
  double tableHeight;
  double minColumnWidth;
  double minRowHeight;

  TableModel({
    required this.cells,
    required this.columnWidths,
    required this.rowHeights,
    required this.numRows,
    required this.numCols,
    required this.defaultCellWidth,
    required this.defaultCellHeight,
    required this.showResizeHandlers,
    required this.tableSize,
    required this.selectedRow,
    required this.selectedColumn,
    required this.tablePosition,
    required this.tableWidth,
    required this.tableHeight,
    required this.minColumnWidth,
    required this.minRowHeight,
  });

  // Add methods to manipulate the table here
  void initializeTable(int rows, int cols) {
    numRows = rows;
    numCols = cols;

    columnWidths = List.generate(numCols, (index) => defaultCellWidth);
    rowHeights = List.generate(numRows, (index) => defaultCellHeight);
    cells = List.generate(
      numRows,
      (row) => List.generate(
        numCols,
        (col) => Cell(content: '', controller: TextEditingController(), color: Colors.white),
      ),
    );

    tableWidth = numCols * defaultCellWidth;
    tableHeight = numRows * defaultCellHeight;

    updateTableSize();
  }

  void updateTableSize() {
    tableSize['rows'] = numRows;
    tableSize['columns'] = numCols;
    tableWidth = columnWidths.reduce((a, b) => a + b);
    tableHeight = rowHeights.reduce((a, b) => a + b);
  }

  // Add more methods as needed

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cells': cells.map((row) => row.map((cell) => cell.toMap()).toList()).toList(),
      'columnWidths': columnWidths,
      'rowHeights': rowHeights,
      'numRows': numRows,
      'numCols': numCols,
      'defaultCellWidth': defaultCellWidth,
      'defaultCellHeight': defaultCellHeight,
      'showResizeHandlers': showResizeHandlers,
      'tableSize': tableSize,
      'selectedRow': selectedRow,
      'selectedColumn': selectedColumn,
      'tablePosition': {'dx': tablePosition.dx, 'dy': tablePosition.dy},
      'tableWidth': tableWidth,
      'tableHeight': tableHeight,
      'minColumnWidth': minColumnWidth,
      'minRowHeight': minRowHeight,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      cells: (map['cells'] as List<dynamic>).map<List<Cell>>((row) => (row as List<dynamic>).map<Cell>((cell) => Cell.fromMap(cell as Map<String, dynamic>)).toList()).toList(),
      columnWidths: List<double>.from((map['columnWidths'] as List<dynamic>).map((item) => item as double)),
      rowHeights: List<double>.from((map['rowHeights'] as List<dynamic>).map((item) => item as double)),
      numRows: map['numRows'] as int,
      numCols: map['numCols'] as int,
      defaultCellWidth: map['defaultCellWidth'] as double,
      defaultCellHeight: map['defaultCellHeight'] as double,
      showResizeHandlers: map['showResizeHandlers'] as bool,
      tableSize: Map<String, int>.from((map['tableSize'] as Map<String, dynamic>)),
      selectedRow: map['selectedRow'] != null ? map['selectedRow'] as int : null,
      selectedColumn: map['selectedColumn'] != null ? map['selectedColumn'] as int : null,
      tablePosition: Offset(map['tablePosition']['dx'] as double, map['tablePosition']['dy'] as double),
      tableWidth: map['tableWidth'] as double,
      tableHeight: map['tableHeight'] as double,
      minColumnWidth: map['minColumnWidth'] as double,
      minRowHeight: map['minRowHeight'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory TableModel.fromJson(String source) => TableModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

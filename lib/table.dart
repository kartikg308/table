import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'models/cell_model.dart';
import 'models/table_model.dart';

class DynamicTable extends StatefulWidget {
  const DynamicTable({super.key});

  @override
  State<DynamicTable> createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  late TableModel tableModel;

  @override
  void initState() {
    super.initState();
    tableModel = TableModel(
      cells: [],
      columnWidths: [],
      rowHeights: [],
      numRows: 2,
      numCols: 2,
      defaultCellWidth: 125,
      defaultCellHeight: 75,
      showResizeHandlers: false,
      tableSize: {'rows': 0, 'columns': 0},
      selectedRow: null,
      selectedColumn: null,
      tablePosition: const Offset(100, 100),
      tableWidth: 250,
      tableHeight: 100,
      minColumnWidth: 75,
      minRowHeight: 50,
    );
    tableModel.initializeTable(tableModel.numRows, tableModel.numCols);
    var toJson = tableModel.toJson();
    print("toJson: $toJson");
    var fromJson = TableModel.fromJson(toJson);
    print("fromJson: $fromJson");
  }

  void _updateTableSize() {
    setState(() {
      tableModel.updateTableSize();
    });
  }

  void _onMoveTable(DragUpdateDetails details) {
    setState(() {
      tableModel.tablePosition += details.delta;
    });
  }

  void _resizeColumn(int col, DragUpdateDetails details) {
    setState(() {
      double delta = details.delta.dx;
      print('Delta X: $delta');

      // Adjust the width of the selected column based on drag distance
      double newWidth = tableModel.columnWidths[col] + delta;
      print('New Width before min check: $newWidth');

      // Ensure the column width doesn't go below the minimum width
      if (newWidth < tableModel.minColumnWidth) {
        newWidth = tableModel.minColumnWidth;
        print('New Width adjusted to minimum: $newWidth');
      }

      // Calculate the difference between the old and new width
      double widthDifference = tableModel.columnWidths[col] - newWidth;
      print('Width Difference: $widthDifference');

      // Set the new width for the selected column
      tableModel.columnWidths[col] = newWidth;
      print('Column $col new width set: ${tableModel.columnWidths[col]}');

      // Adjust the neighboring column (if it exists) to maintain the total table width
      if (col + 1 < tableModel.columnWidths.length) {
        double neighborNewWidth = tableModel.columnWidths[col + 1] + widthDifference;
        print('Neighbor Column ${col + 1} new width before min check: $neighborNewWidth');

        // Ensure the neighboring column width doesn't go below the minimum width
        if (neighborNewWidth < tableModel.minColumnWidth) {
          // If neighbor would go below minimum, adjust the delta to reduce the resizing
          double extraWidth = tableModel.minColumnWidth - neighborNewWidth;
          tableModel.columnWidths[col] -= extraWidth;
          neighborNewWidth = tableModel.minColumnWidth;
          print('Neighbor Column ${col + 1} new width adjusted to minimum: $neighborNewWidth');
        }

        // Adjust the neighboring column's width
        tableModel.columnWidths[col + 1] = neighborNewWidth;
        print('Neighbor Column ${col + 1} new width set: ${tableModel.columnWidths[col + 1]}');
      } else if (col > 0) {
        // If there's no column to the right, adjust the previous column
        double prevNeighborNewWidth = tableModel.columnWidths[col - 1] + widthDifference;
        print('Previous Neighbor Column ${col - 1} new width before min check: $prevNeighborNewWidth');

        // Ensure the previous neighboring column width doesn't go below the minimum width
        if (prevNeighborNewWidth < tableModel.minColumnWidth) {
          // If previous neighbor would go below minimum, adjust the delta to reduce the resizing
          double extraWidth = tableModel.minColumnWidth - prevNeighborNewWidth;
          tableModel.columnWidths[col] -= extraWidth;
          prevNeighborNewWidth = tableModel.minColumnWidth;
          print('Previous Neighbor Column ${col - 1} new width adjusted to minimum: $prevNeighborNewWidth');
        }

        // Adjust the previous column's width
        tableModel.columnWidths[col - 1] = prevNeighborNewWidth;
        print('Previous Neighbor Column ${col - 1} new width set: ${tableModel.columnWidths[col - 1]}');
      }

      // Ensure the total table width remains constant
      _updateTableSizeWithFixedTotalWidth();
    });
  }

  void _updateTableSizeWithFixedTotalWidth() {
    // Ensure the total width of the table remains constant
    double totalColumnWidth = tableModel.columnWidths.reduce((a, b) => a + b);
    double fixedTableWidth = tableModel.tableWidth;

    if (totalColumnWidth != fixedTableWidth) {
      // Adjust the last column to make sure the total width remains constant
      double adjustment = fixedTableWidth - totalColumnWidth;
      tableModel.columnWidths[tableModel.columnWidths.length - 1] += adjustment;
    }
  }

  Widget _buildColumnResizeHandler(int colIndex) {
    return Positioned(
      left: tableModel.columnWidths.sublist(0, colIndex).fold(0.0, (sum, w) => sum + w) - 10,
      top: 0,
      child: GestureDetector(
        onPanStart: (details) {
          print('Dragging column on start: $colIndex');
        },
        onPanUpdate: (details) {
          print('Dragging column: $colIndex');
          _resizeColumn(colIndex - 1, details);
        },
        child: Container(
          width: 20,
          height: 20,
          color: Colors.blue,
          child: const MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Center(
              child: Icon(
                Icons.drag_handle,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildColumnResizeHandlers() {
    List<Widget> handlers = [];
    if (tableModel.selectedColumn! < tableModel.columnWidths.length - 1) {
      handlers.add(_buildColumnResizeHandler(tableModel.selectedColumn! + 1));
    }
    if (tableModel.selectedColumn! > 0) {
      handlers.add(_buildColumnResizeHandler(tableModel.selectedColumn!));
    }
    return handlers;
  }

  void _resizeRow(int row, DragUpdateDetails details) {
    setState(() {
      double delta = details.delta.dy;
      print('Delta Y: $delta');

      // Adjust the height of the selected row based on drag distance
      double newHeight = tableModel.rowHeights[row] + delta;
      print('New Height before min check: $newHeight');

      // Ensure the row height doesn't go below the minimum height
      if (newHeight < tableModel.minRowHeight) {
        newHeight = tableModel.minRowHeight;
        print('New Height adjusted to minimum: $newHeight');
      }

      // Calculate the difference between the old and new height
      double heightDifference = tableModel.rowHeights[row] - newHeight;
      print('Height Difference: $heightDifference');

      // Set the new height for the selected row
      tableModel.rowHeights[row] = newHeight;
      print('Row $row new height set: ${tableModel.rowHeights[row]}');

      // Adjust the neighboring row (if it exists) to maintain the total table height
      if (row + 1 < tableModel.rowHeights.length) {
        double neighborNewHeight = tableModel.rowHeights[row + 1] + heightDifference;
        print('Neighbor Row ${row + 1} new height before min check: $neighborNewHeight');

        // Ensure the neighboring row height doesn't go below the minimum height
        if (neighborNewHeight < tableModel.minRowHeight) {
          // If neighbor would go below minimum, adjust the delta to reduce the resizing
          double extraHeight = tableModel.minRowHeight - neighborNewHeight;
          tableModel.rowHeights[row] -= extraHeight;
          neighborNewHeight = tableModel.minRowHeight;
          print('Neighbor Row ${row + 1} new height adjusted to minimum: $neighborNewHeight');
        }

        // Adjust the neighboring row's height
        tableModel.rowHeights[row + 1] = neighborNewHeight;
        print('Neighbor Row ${row + 1} new height set: ${tableModel.rowHeights[row + 1]}');
      } else if (row > 0) {
        // If there's no row below, adjust the previous row
        double prevNeighborNewHeight = tableModel.rowHeights[row - 1] + heightDifference;
        print('Previous Neighbor Row ${row - 1} new height before min check: $prevNeighborNewHeight');

        // Ensure the previous neighboring row height doesn't go below the minimum height
        if (prevNeighborNewHeight < tableModel.minRowHeight) {
          // If previous neighbor would go below minimum, adjust the delta to reduce the resizing
          double extraHeight = tableModel.minRowHeight - prevNeighborNewHeight;
          tableModel.rowHeights[row] -= extraHeight;
          prevNeighborNewHeight = tableModel.minRowHeight;
          print('Previous Neighbor Row ${row - 1} new height adjusted to minimum: $prevNeighborNewHeight');
        }

        // Adjust the previous row's height
        tableModel.rowHeights[row - 1] = prevNeighborNewHeight;
        print('Previous Neighbor Row ${row - 1} new height set: ${tableModel.rowHeights[row - 1]}');
      }

      // Ensure the total table height remains constant
      _updateTableSizeWithFixedTotalHeight();
    });
  }

  void _updateTableSizeWithFixedTotalHeight() {
    // Ensure the total height of the table remains constant
    double totalRowHeight = tableModel.rowHeights.reduce((a, b) => a + b);
    double fixedTableHeight = tableModel.tableHeight;

    if (totalRowHeight != fixedTableHeight) {
      // Adjust the last row to make sure the total height remains constant
      double adjustment = fixedTableHeight - totalRowHeight;
      tableModel.rowHeights[tableModel.rowHeights.length - 1] += adjustment;
    }
  }

  Widget _buildRowResizeHandler(int rowIndex) {
    return Positioned(
      left: -10,
      top: tableModel.rowHeights.sublist(0, rowIndex).fold(0.0, (sum, h) => sum + h) - 10,
      child: GestureDetector(
        onPanUpdate: (details) => _resizeRow(rowIndex - 1, details),
        child: Container(
          width: 20,
          height: 20,
          color: Colors.green,
          child: const MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: Center(
              child: Icon(
                Icons.drag_handle,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowResizeHandlers() {
    List<Widget> handlers = [];
    if (tableModel.selectedRow! < tableModel.rowHeights.length - 1) {
      handlers.add(_buildRowResizeHandler(tableModel.selectedRow! + 1));
    }
    if (tableModel.selectedRow! > 0) {
      handlers.add(_buildRowResizeHandler(tableModel.selectedRow!));
    }
    return handlers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Positioned for the draggable and resizable table
          Positioned(
            left: tableModel.tablePosition.dx,
            top: tableModel.tablePosition.dy,
            child: GestureDetector(
              onPanUpdate: _onMoveTable, // Dragging the entire table
              child: Stack(
                children: [
                  // The original scrollable table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: _calculateTotalWidth(),
                        height: _calculateTotalHeight(),
                        child: Stack(
                          children: [
                            // Cell Rendering
                            for (int row = 0; row < tableModel.numRows; row++)
                              for (int col = 0; col < tableModel.numCols; col++) _buildCell(row, col),

                            // Create resize handlers for the selected column
                            if (tableModel.selectedColumn != null) ..._buildColumnResizeHandlers(),

                            // Create resize handlers for the selected row
                            if (tableModel.selectedRow != null) ..._buildRowResizeHandlers(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotalWidth() {
    return tableModel.columnWidths.isNotEmpty ? tableModel.columnWidths.reduce((a, b) => a + b) : tableModel.numCols * tableModel.defaultCellWidth;
  }

  double _calculateTotalHeight() {
    return tableModel.rowHeights.isNotEmpty ? tableModel.rowHeights.reduce((a, b) => a + b) : tableModel.numRows * tableModel.defaultCellHeight;
  }

  void _addRowAbove(int row) {
    setState(() {
      tableModel.numRows++;

      // Set the height of the new row to match the adjacent row
      double adjacentRowHeight = tableModel.rowHeights[row];

      tableModel.rowHeights.insert(row, adjacentRowHeight);

      // Insert the new row's cells with default properties
      tableModel.cells.insert(row, List.generate(tableModel.numCols, (col) => Cell(content: '', controller: TextEditingController())));

      _updateTableSize(); // Update table size after adding row
      tableModel.selectedColumn = null;
      tableModel.selectedRow = null;
    });
  }

  void _addRowBelow(int row) {
    setState(() {
      tableModel.numRows++;

      // Set the height of the new row to match the adjacent row
      double adjacentRowHeight = tableModel.rowHeights[row];
      tableModel.rowHeights.insert(row + 1, adjacentRowHeight);

      // Insert the new row's cells with default properties
      tableModel.cells.insert(row + 1, List.generate(tableModel.numCols, (col) => Cell(content: '', controller: TextEditingController())));
      tableModel.selectedColumn = null;
      tableModel.selectedRow = null;

      _updateTableSize(); // Update table size after adding row
    });
  }

  void _addColumnLeft(int col) {
    setState(() {
      tableModel.numCols++;

      // Set the width of the new column to match the adjacent column
      double adjacentColumnWidth = tableModel.columnWidths[col];
      tableModel.columnWidths.insert(col, adjacentColumnWidth);

      // Insert the new column's cells with default properties
      for (int i = 0; i < tableModel.numRows; i++) {
        tableModel.cells[i].insert(col, Cell(content: '', controller: TextEditingController()));
      }
      tableModel.selectedColumn = null;
      tableModel.selectedRow = null;

      _updateTableSize(); // Update table size after adding column
    });
  }

  void _addColumnRight(int col) {
    setState(() {
      tableModel.numCols++;

      // Set the width of the new column to match the adjacent column
      double adjacentColumnWidth = tableModel.columnWidths[col];
      tableModel.columnWidths.insert(col + 1, adjacentColumnWidth);

      // Insert the new column's cells with default properties
      for (int i = 0; i < tableModel.numRows; i++) {
        tableModel.cells[i].insert(col + 1, Cell(content: '', controller: TextEditingController()));
      }

      tableModel.selectedColumn = null;
      tableModel.selectedRow = null;

      _updateTableSize(); // Update table size after adding column
    });
  }

  void _onCellTap(int row, int col) {
    setState(() {
      // Reset the selected row and column if the user taps on another cell
      tableModel.selectedRow = row;
      tableModel.selectedColumn = col;

      tableModel.showResizeHandlers = true;
    });
  }

  void _deleteRow(int row) {
    if (tableModel.rowHeights.length <= 1) {
      return;
    }
    setState(() {
      tableModel.cells.removeAt(row);
      tableModel.numRows--;
      tableModel.rowHeights.removeAt(row);

      _updateTableSize();
    });
  }

  void _deleteColumn(int col) {
    if (tableModel.columnWidths.length <= 1) {
      return;
    }
    setState(() {
      if (col >= 0 && col < tableModel.numCols) {
        // Remove the column from each row in the table
        for (var row in tableModel.cells) {
          if (row.length > col) {
            row.removeAt(col);
          }
        }
        tableModel.numCols--;

        if (tableModel.columnWidths.length > col) {
          tableModel.columnWidths.removeAt(col);
        }
      }
      _updateTableSize();
    });
  }

  void _showColorPickerDialog(int row, int col) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tableModel.cells[row][col].color,
              onColorChanged: (color) {
                setState(() {
                  tableModel.cells[row][col].color = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _cellDialogContent(int row, int col) {
    return AlertDialog(
      title: const Text('Choose your options'),
      content: SizedBox(
        width: 200,
        height: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _addRowAbove(row);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward),
                  SizedBox(width: 8),
                  Text('Insert Row Above'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addRowBelow(row);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward),
                  SizedBox(width: 8),
                  Text('Insert Row Below'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addColumnLeft(col);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text('Insert Column Left'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _addColumnRight(col);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8),
                  Text('Insert Column Right'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteRow(row);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete Entire Row'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteColumn(col);
                Navigator.of(context).pop();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete Entire Column'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showColorPickerDialog(row, col);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.format_color_fill),
                  SizedBox(width: 8),
                  Text("Fill Color"),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showCellOptionsDialog(int row, int col) {
    // Initial position of the dialog
    Offset dialogPosition = const Offset(400, 100); // Default position

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                Positioned(
                  left: dialogPosition.dx,
                  top: dialogPosition.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      // Update dialog position during dragging
                      setState(() {
                        dialogPosition = Offset(
                          dialogPosition.dx + details.delta.dx,
                          dialogPosition.dy + details.delta.dy,
                        );
                      });
                    },
                    child: _cellDialogContent(row, col),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCell(int row, int col) {
    return Positioned(
      left: tableModel.columnWidths.sublist(0, col).fold(0.0, (sum, w) => (sum ?? 0) + w),
      top: tableModel.rowHeights.sublist(0, row).fold(0.0, (sum, h) => (sum ?? 0) + h),
      width: tableModel.columnWidths.sublist(col, (col + tableModel.cells[row][col].colSpan).toInt()).fold(0.0, (sum, w) => (sum ?? 0) + w),
      height: tableModel.rowHeights.sublist(row, (row + tableModel.cells[row][col].rowSpan).toInt()).fold(0.0, (sum, h) => (sum ?? 0) + h),
      child: GestureDetector(
        onDoubleTap: () {
          _showCellOptionsDialog(row, col);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              color: tableModel.cells[row][col].color,
            ),
            child: DottedBorder(
              color: Colors.black,
              strokeWidth: 1,
              dashPattern: const [6, 3, 6, 3],
              child: TextField(
                onTap: () => _onCellTap(row, col),
                controller: tableModel.cells[row][col].controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Add Data",
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  border: InputBorder.none,
                ),
                onChanged: (text) {
                  setState(() {
                    tableModel.cells[row][col].content = text;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

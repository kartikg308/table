import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return const MaterialApp(
        home: DynamicTableScreen(),
      );
    }
  }

  class DynamicTableScreen extends StatefulWidget {
    const DynamicTableScreen({super.key});

    @override
    _DynamicTableScreenState createState() => _DynamicTableScreenState();
  }

  class _DynamicTableScreenState extends State<DynamicTableScreen> {
    List<List<Cell>> cells = [];
    List<TextEditingController> headerControllers = [];
    List<bool> columnSelected = [];
    List<double> columnWidths = [];
    List<double> rowHeights = [];
    int numRows = 2;
    int numCols = 2;
    double defaultCellWidth = 150;
    double defaultCellHeight = 50;
    final List<Color> _rowColors = List.generate(2, (_) => Colors.white);
    final List<Color> _columnColors = List.generate(5, (_) => Colors.transparent);
    

    @override
    void initState() {
      super.initState();
      _initializeTableData();
    }

    void _initializeTableData() {
      cells = List.generate(
        numRows,
        (row) => List.generate(
          numCols,
          (col) => Cell(
              content: '',
              controller: TextEditingController(),
              color: Colors.white),
        ),
      );
      headerControllers = List.generate(
        numCols,
        (col) => TextEditingController(text: 'Column ${col + 1}'),
      );
      columnSelected = List.generate(numCols, (_) => false);
      columnWidths = List.generate(numCols, (_) => 150);
      rowHeights = List.generate(numRows, (_) => 50);
    }

    void _addRow() {
      setState(() {
        numRows++;
        cells.add(List.generate(numCols,
            (col) => Cell(content: '', controller: TextEditingController())));
        rowHeights.add(defaultCellHeight);
      });
    }

    void _addColumn() {
      setState(() {
        numCols++;
        columnSelected.add(false);
        columnWidths.add(defaultCellWidth);
        for (int i = 0; i < numRows; i++) {
          cells[i].add(Cell(content: '', controller: TextEditingController()));
        }
        headerControllers.add(TextEditingController(text: 'Column $numCols'));
      });
    }

    void _showEditDialog(int col) {
      TextEditingController editController = TextEditingController(
        text: headerControllers[col].text,
      );


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Column Name'),
            content: TextField(
              controller: editController,
              decoration:
                  const InputDecoration(hintText: 'Enter new column name'),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() {
                    headerControllers[col].text = editController.text;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _showAddDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Option'),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Add Row'),
                onPressed: () {
                  _addRow();
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Add Column'),
                onPressed: () {
                  _addColumn();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } 


    void _deleteRow(int row) {
      setState(() {
        cells.removeAt(row);
        numRows--;
        rowHeights.removeAt(row);
      });
    }

    void _deleteSelectedColumns() {
      setState(() {
        for (int i = columnSelected.length - 1; i >= 0; i--) {
          if (columnSelected[i]) {
            headerControllers.removeAt(i);
            columnSelected.removeAt(i);
            columnWidths.removeAt(i);
            for (int j = 0; j < numRows; j++) {
              cells[j].removeAt(i);
            }
            numCols--;
          }
        }
      });
    }

    void _mergeTop(int row, int col) {
  if (row > 0 &&
      !cells[row][col].isMerged &&
      !cells[row - 1][col].isMerged &&
      cells[row - 1][col].rowSpan == 1 &&
      cells[row - 1][col].colSpan == 1 &&
      cells[row][col].colSpan == 1 &&
      cells[row][col].rowSpan == 1) {
    setState(() {
      cells[row - 1][col].content = cells[row - 1][col].content.isEmpty
          ? cells[row][col].content
          : '${cells[row - 1][col].content}\n${cells[row][col].content}';
      // Increase rowSpan of the top cell
      cells[row - 1][col].rowSpan += cells[row][col].rowSpan;
      // Mark the current cell as merged and reference the top cell
      cells[row][col].isMerged = true;
      cells[row][col].mergedWith = cells[row - 1][col];
      cells[row][col].content = '';
    });
  }
}

void _mergeLeft(int row, int col) {
  if (col > 0 &&
      !cells[row][col].isMerged &&
      !cells[row][col - 1].isMerged &&
      cells[row][col - 1].colSpan == 1 &&
      cells[row][col - 1].rowSpan == 1 &&
      cells[row][col].colSpan == 1 &&
      cells[row][col].rowSpan == 1) {
    setState(() {
      // Increase colSpan of the left cell
     cells[row][col - 1].colSpan += cells[row][col].colSpan;
      cells[row][col - 1].content += ' ${cells[row][col].content}';
      // Mark the current cell as merged and reference the left cell
      cells[row][col].isMerged = true;
      cells[row][col].mergedWith = cells[row][col - 1];
      cells[row][col].content = '';
    });
  }
}

void _mergeRight(int row, int col) {
  if (col + 1 < cells[row].length &&
      !cells[row][col].isMerged &&
      !cells[row][col + 1].isMerged &&
      cells[row][col + 1].colSpan == 1 &&
      cells[row][col + 1].rowSpan == 1 &&
      cells[row][col].colSpan == 1 &&
      cells[row][col].rowSpan == 1) {
    setState(() {
      // Increase colSpan of the current cell
      cells[row][col].colSpan += cells[row][col + 1].colSpan;
      cells[row][col].content += ' ${cells[row][col + 1].content}';
      // Mark the right cell as merged and reference the current cell
      cells[row][col + 1].isMerged = true;
      cells[row][col + 1].mergedWith = cells[row][col];
      cells[row][col + 1].content = '';
    });
  }
}

void _mergeBottom(int row, int col) {
  if (row + 1 < cells.length &&
      !cells[row][col].isMerged &&
      !cells[row + 1][col].isMerged &&
      cells[row + 1][col].colSpan == 1 &&
      cells[row + 1][col].rowSpan == 1 &&
      cells[row][col].colSpan == 1 &&
      cells[row][col].rowSpan == 1) {
    setState(() {
      cells[row][col].content = cells[row][col].content.isEmpty
          ? cells[row + 1][col].content
          : '${cells[row][col].content}\n${cells[row + 1][col].content}';
      // Increase rowSpan of the current cell
      cells[row][col].rowSpan += cells[row + 1][col].rowSpan;
      // Mark the bottom cell as merged and reference the current cell
      cells[row + 1][col].isMerged = true;
      cells[row + 1][col].mergedWith = cells[row][col];
      cells[row + 1][col].content = '';
    });
  }
}


  void _showCellOptionsDialog(int row, int col) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    _mergeRight(row, col);
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward),
                      SizedBox(width: 8),
                      Text('Merge Right'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _mergeTop(row, col);
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward),
                      SizedBox(width: 8),
                      Text('Merge Top'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _mergeLeft(row, col);
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 8),
                      Text('Merge Left'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _mergeBottom(row, col);
                    Navigator.of(context).pop();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward),
                      SizedBox(width: 8),
                      Text('Merge Bottom'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('Adding row above row $row');
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
                    print('Adding row below row $row');
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
                    print('Adding col left col $col');
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
                    print('Adding col right col $col');
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
      },
    );
  }


  void _addColumnLeft(int col) {
  setState(() {
    numCols++;

    columnSelected.insert(col, false);
    columnWidths.insert(col, defaultCellWidth);
    for (int i = 0; i < numRows; i++) {
      cells[i].insert(col, Cell(content: '', controller: TextEditingController()));
    }
    headerControllers.insert(col, TextEditingController(text: 'Column ${col + 1}'));

    // Update column indices in header controllers                
    for (int i = col + 1; i < headerControllers.length; i++) {
      headerControllers[i].text = 'Column ${i + 1}';
    }
  });
}

  void _addColumnRight(int col) {
    setState(() {
      numCols++;
      columnSelected.insert(col + 1, false);
      columnWidths.insert(col + 1, defaultCellWidth);
      for (int i = 0; i < numRows; i++) {
        cells[i].insert(col + 1, Cell(content: '', controller: TextEditingController()));
      }
      headerControllers.insert(col + 1, TextEditingController(text: 'Column ${col + 2}'));

      
      for (int i = col + 2; i < headerControllers.length; i++) {
        headerControllers[i].text = 'Column ${i + 1}';
      }
    });
  }


  void _addRowAbove(int row) {
    setState(() {
      numRows++;
      rowHeights.insert(row, defaultCellHeight);
      cells.insert(row, List.generate(numCols,
          (col) => Cell(content: '', controller: TextEditingController())));
    });
  }

  
  void _addRowBelow(int row) {
    setState(() {
      numRows++;
      rowHeights.insert(row + 1, defaultCellHeight);
      cells.insert(row + 1, List.generate(numCols,
          (col) => Cell(content: '', controller: TextEditingController())));
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
                pickerColor: cells[row][col].color,
                onColorChanged: (color) {
                  setState(() {
                    cells[row][col].color = color;
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

 void _resizeColumn(int col, DragUpdateDetails details) {
  setState(() {
    double delta = details.primaryDelta!;
    double newWidth = (columnWidths[col] ?? defaultCellWidth) + delta;

    // Update the width of the column being resized
    columnWidths[col] = newWidth;

    // Update widths for all columns in the merged group
    for (int i = 0; i < numRows; i++) {
      Cell cell = cells[i][col];
      Cell? rootCell = cell.mergedWith ?? cell;

      if (rootCell != cell) {
        // Find the start and end columns for the merged group
        int startCol = col;
        int endCol = col;

        while (startCol > 0 && cells[i][startCol - 1].mergedWith == rootCell) {
          startCol--;
        }
        while (endCol < numCols - 1 && cells[i][endCol + 1].mergedWith == rootCell) {
          endCol++;
        }

        // Total width of the merged columns
        double totalWidth = 0;
        for (int j = startCol; j <= endCol; j++) {
          totalWidth += columnWidths[j] ?? defaultCellWidth;
        }

        // Recalculate widths proportionally
        double proportion = (columnWidths[col] ?? defaultCellWidth) / totalWidth;
        for (int j = startCol; j <= endCol; j++) {
          columnWidths[j] = proportion * (totalWidth + delta);
        }
      }
    }
  });
}


void _resizeRow(int row, DragUpdateDetails details) {
  setState(() {
    double delta = details.primaryDelta!;
    double newHeight = (rowHeights[row] ?? defaultCellHeight) + delta;

    rowHeights[row] = newHeight;

    // Adjust heights of merged cells
    for (int i = 0; i < numCols; i++) {
      var rootCell = cells[row][i].mergedWith ?? cells[row][i];
      if (rootCell != cells[row][i]) {
        int startRow = row;
        int endRow = row;

        // Find the  start and end rows based on merges
        while (startRow > 0 && cells[startRow - 1][i].mergedWith == rootCell) {
          startRow--;
        }
        while (endRow < numRows - 1 && cells[endRow + 1][i].mergedWith == rootCell) {
          endRow++;
        }

        // Total height of the merged rows
        double totalHeight = 0;
        for (int j = startRow; j <= endRow; j++) {
          totalHeight += rowHeights[j] ?? defaultCellHeight;
        }

        for (int j = startRow; j <= endRow; j++) {
          double proportion = (rowHeights[j] ?? defaultCellHeight) / totalHeight;
          rowHeights[j] = proportion * (totalHeight + delta);
        }
      }
    }
  });
}

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Table Assignment'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              width: (numCols +
                      2) * // Increased by 2 to accommodate the Actions column and the extra column for dragging and deleting
                  (columnWidths.isNotEmpty
                      ? columnWidths.reduce((a, b) => a + b)
                      : defaultCellWidth), // +1 for the Actions column
              height: (numRows + 1) *
                  (rowHeights.isNotEmpty
                      ? rowHeights.reduce((a, b) => a + b)
                      : defaultCellHeight), // +1 for the header row
              child: Stack(
                children: [
                  // Headers
                  for (int col = 0; col < numCols; col++)
                    Positioned(
                      left: columnWidths
                          .sublist(0, col)
                          .fold(0.0, (sum, w) => (sum ?? 0) + (w ?? 0)),
                      top: 0,
                      width: columnWidths[col],
                      height: defaultCellHeight,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: columnSelected[col],
                                onChanged: (bool? value) {
                                  setState(() {
                                    columnSelected[col] = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text(
                                  headerControllers[col].text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () {
                                  _showEditDialog(col);
                                },
                              ),
                              const VerticalDivider(
                                thickness: 1,
                                color: Colors.grey,
                                width: 10,
                                indent: 7,
                                endIndent: 7,
                              ),
                              GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  _resizeColumn(col, details);
                                },
                                child: const MouseRegion(
                                  cursor: SystemMouseCursors.resizeColumn,
                                  child: Icon(Icons.drag_indicator),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Actions column header
                  Positioned(
                    left: columnWidths
                        .sublist(0, numCols)
                        .fold(0.0, (sum, w) => (sum ?? 0) + (w ?? 0)),
                    top: 0,
                    width: defaultCellWidth,
                    height: defaultCellHeight,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Rows and Actions column with delete buttons
                  for (int row = 0; row < numRows; row++) 
                    for (int col = 0; col < numCols; col++)
                      if (!cells[row][col].isMerged)
                        Positioned(
                          left: columnWidths
                              .sublist(0, col)
                              .fold(0.0, (sum, w) => (sum ?? 0) + (w ?? 0)),
                          top: rowHeights.sublist(0, row).fold(defaultCellHeight,
                              (sum, h) => (sum ?? 0) + (h ?? 0)),
                          width: columnWidths.sublist(col, col + cells[row][col].colSpan).fold(0.0, (sum,w) =>(sum ?? 0) + (w ?? defaultCellWidth)),
                          height:  rowHeights.sublist(row, row + cells[row][col].rowSpan).fold(0.0, (sum, h) => (sum ?? 0) + (h ?? defaultCellHeight)),
                          child: GestureDetector(
                            onDoubleTap: () {
                              _showCellOptionsDialog(row, col);
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cells[row][col].color,
                                  border: Border.all(color: Colors.black),
                                ),
                                child: TextField(
                                  controller: cells[row][col].controller,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    hintText: "Add Data",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                  // Actions column buttons
                  for (int row = 0; row < numRows; row++)
                    Positioned(
                      left: columnWidths
                          .sublist(0, numCols)
                          .fold(0.0, (sum, w) => (sum ?? 0) + (w ?? 0)),
                      top: rowHeights.sublist(0, row).fold(
                          defaultCellHeight, (sum, h) => (sum ?? 0) + (h ?? 0)),
                      width: defaultCellWidth,
                      height: rowHeights[row],
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onVerticalDragUpdate: (details) {
                                _resizeRow(row, details);
                              },
                              child: const MouseRegion(
                                cursor: SystemMouseCursors.resizeRow,
                                child: Icon(Icons.drag_indicator),
                              ),
                            ),
                            const VerticalDivider(
                              thickness: 1,
                              color: Colors.grey,
                              width: 10,
                              indent: 7,
                              endIndent: 7,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteRow(row);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
            floatingActionButton:FloatingActionButton(
              onPressed: _deleteSelectedColumns,
              tooltip: 'Delete',
              child: const Icon(Icons.delete),
            ),
      );
    }
  }



  class Cell {
    String content;
    bool isMerged;
    int colSpan;
    int rowSpan;
    TextEditingController controller;
    Color color;
    Cell? mergedWith;

    Cell({
      required this.content,
      this.isMerged = false,
      this.colSpan = 1,
      this.rowSpan = 1,
      required this.controller,
      this.color = Colors.white,
      this.mergedWith,
    });
  }

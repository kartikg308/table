import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dotted_border/dotted_border.dart';

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
    List<double> columnWidths = [];
    List<double> rowHeights = [];
    int numRows = 2;
    int numCols = 2;
    double defaultCellWidth = 125;
    double defaultCellHeight = 50;
    bool showResizeHandlers = false;
    Map<String, int> tableSize = {
    'rows': 0,
    'columns': 0,
  };
  int? selectedRow;
  int? selectedColumn;
  Offset tablePosition = const Offset(100,100); // Initial position of the table
  late double tableWidth ; // Initial table width
  late double tableHeight ; // Initial table height

  // Define these constants at the beginning of your class
  final double minimumCellWidth = 50.0;  
  final double minimumCellHeight = 30.0; 


    @override
    void initState() {
    super.initState();
    // Initialize table with default size
    _initializeTable(numRows, numCols);

  }

  

void _initializeTable(int rows, int cols) {
    setState(() {
      numRows = rows;
      numCols = cols;

      // Initialize the cells, columnSelected, columnWidths, rowHeights
      columnWidths = List.generate(numCols, (index) => defaultCellWidth);
      rowHeights = List.generate(numRows, (index) => defaultCellHeight);
      cells = List.generate(
          numRows,
          (row) => List.generate(
              numCols,
              (col) => Cell(content: '', controller: TextEditingController() ,color: Colors.white),));

               tableWidth = numCols * defaultCellWidth;
               tableHeight = numRows * defaultCellHeight;


      // Update the table size
      _updateTableSize();
    });
  }

  // Method to track and update the size of the table
void _updateTableSize() {
    setState(() {
      tableSize['rows'] = numRows;
      tableSize['columns'] = numCols;
      tableWidth = columnWidths.reduce((a, b)=>a+b);
      tableHeight = rowHeights.reduce((a, b)=>a+b);
  });
}

void _onMoveTable(DragUpdateDetails details) {
    setState(() {
      tablePosition += details.delta;
    });
  }

void _onCellTap(int row, int col) {
 setState(() {
     
    // Reset the selected row and column if the user taps on another cell
      selectedRow = row;
      selectedColumn = col;

      showResizeHandlers = true;
      
    });
}

void _deleteRow(int row) {
      if(rowHeights.length <=1){
        return;
      }
      setState(() {
        cells.removeAt(row);
        numRows--;
        rowHeights.removeAt(row);

        _updateTableSize();
      });
    }

void _deleteColumn(int col) {
  if(columnWidths.length<=1){
    return;
  }
  setState(() {
    if (col >= 0 && col < numCols) {
      // Remove the column from each row in the table
      for (List<Cell> row in cells) {
        if (row.length > col) {
          row.removeAt(col);
        }
      }
      numCols--;

      if (columnWidths.length > col) {
        columnWidths.removeAt(col);
      }
    }
    _updateTableSize();
  });
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

void _addColumnLeft(int col) {
  setState(() {
    numCols++;

    // Set the width of the new column to match the adjacent column
    double adjacentColumnWidth = columnWidths[col];
    columnWidths.insert(col, adjacentColumnWidth);


    // Insert the new column's cells with default properties
    for (int i = 0; i < numRows; i++) {
      cells[i].insert(col, Cell(content: '', controller: TextEditingController()));
    }
    selectedColumn=null;
    selectedRow=null;


    _updateTableSize(); // Update table size after adding column
  });
}

void _addColumnRight(int col) {
  setState(() {
    numCols++;

    // Set the width of the new column to match the adjacent column
    double adjacentColumnWidth = columnWidths[col];
    columnWidths.insert(col + 1, adjacentColumnWidth);


    // Insert the new column's cells with default properties
    for (int i = 0; i < numRows; i++) {
      cells[i].insert(col + 1, Cell(content: '', controller: TextEditingController()));
    }

    selectedColumn=null;
    selectedRow=null;

    _updateTableSize(); // Update table size after adding column
  });
}

void _addRowAbove(int row) {
  setState(() {
    numRows++;

    // Set the height of the new row to match the adjacent row
    double adjacentRowHeight = rowHeights[row];
    rowHeights.insert(row, adjacentRowHeight);

    // Insert the new row's cells with default properties
    cells.insert(row, List.generate(numCols, (col) => Cell(content: '', controller: TextEditingController())));

    _updateTableSize(); // Update table size after adding row
    selectedColumn=null;
    selectedRow=null;
  });
}

void _addRowBelow(int row) {
  setState(() {
    numRows++;

    // Set the height of the new row to match the adjacent row
    double adjacentRowHeight = rowHeights[row];
    rowHeights.insert(row + 1, adjacentRowHeight);

    // Insert the new row's cells with default properties
    cells.insert(row + 1, List.generate(numCols, (col) => Cell(content: '', controller: TextEditingController())));
    selectedColumn=null;
    selectedRow=null;

    _updateTableSize(); // Update table size after adding row
  });
}

void  _showColorPickerDialog(int row, int col) {
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
    double delta = details.delta.dx;

    // Adjust the width of the selected column based on drag distance
    double newWidth = columnWidths[col] + delta;

    // Ensure the column width doesn't go below the minimum width
    if (newWidth < minimumCellWidth) {
      newWidth = minimumCellWidth;
    }

    // Calculate the difference between the old and new width
    double widthDifference = columnWidths[col] - newWidth;

    // Set the new width for the selected column
    columnWidths[col] = newWidth;

    // Adjust the neighboring column (if it exists) to maintain the total table width
    if (col + 1 < columnWidths.length) {
      double neighborNewWidth = columnWidths[col + 1] + widthDifference;

      // Ensure the neighboring column width doesn't go below the minimum width
      if (neighborNewWidth < minimumCellWidth) {
        // If neighbor would go below minimum, adjust the delta to reduce the resizing
        double extraWidth = minimumCellWidth - neighborNewWidth;
        columnWidths[col] -= extraWidth;
        neighborNewWidth = minimumCellWidth;
      }

      // Adjust the neighboring column's width
      columnWidths[col + 1] = neighborNewWidth;
    } else if (col > 0) {
      // If there's no column to the right, adjust the previous column
      double prevNeighborNewWidth = columnWidths[col - 1] + widthDifference;

      // Ensure the previous neighboring column width doesn't go below the minimum width
      if (prevNeighborNewWidth < minimumCellWidth) {
        // If previous neighbor would go below minimum, adjust the delta to reduce the resizing
        double extraWidth = minimumCellWidth - prevNeighborNewWidth;
        columnWidths[col] -= extraWidth;
        prevNeighborNewWidth = minimumCellWidth;
      }

      // Adjust the previous column's width
      columnWidths[col - 1] = prevNeighborNewWidth;
    }

    // Ensure the total table width remains constant
    _updateTableSizeWithFixedTotalWidth();
  });
}

void _resizeRow(int row, DragUpdateDetails details) {
  setState(() {
    double delta = details.delta.dy;

    // Adjust the height of the selected row based on drag distance
    double newHeight = rowHeights[row] + delta;

    // Ensure the row height doesn't go below the minimum height
    if (newHeight < minimumCellHeight) {
      newHeight = minimumCellHeight;
    }

    // Calculate the difference between the old and new height
    double heightDifference = rowHeights[row] - newHeight;

    // Set the new height for the selected row
    rowHeights[row] = newHeight;

    // Adjust the neighboring row (if it exists) to maintain the total table height
    if (row + 1 < rowHeights.length) {
      double neighborNewHeight = rowHeights[row + 1] + heightDifference;

      // Ensure the neighboring row height doesn't go below the minimum height
      if (neighborNewHeight < minimumCellHeight) {
        // If neighbor would go below minimum, adjust the delta to reduce the resizing
        double extraHeight = minimumCellHeight - neighborNewHeight;
        rowHeights[row] -= extraHeight;
        neighborNewHeight = minimumCellHeight;
      }

      // Adjust the neighboring row's height
      rowHeights[row + 1] = neighborNewHeight;
    } else if (row > 0) {
      // If there's no row below, adjust the previous row
      double prevNeighborNewHeight = rowHeights[row - 1] + heightDifference;

      // Ensure the previous neighboring row height doesn't go below the minimum height
      if (prevNeighborNewHeight < minimumCellHeight) {
        // If previous neighbor would go below minimum, adjust the delta to reduce the resizing
        double extraHeight = minimumCellHeight - prevNeighborNewHeight;
        rowHeights[row] -= extraHeight;
        prevNeighborNewHeight = minimumCellHeight;
      }

      // Adjust the previous row's height
      rowHeights[row - 1] = prevNeighborNewHeight;
    }

    // Ensure the total table height remains constant
    _updateTableSizeWithFixedTotalHeight();
  });
}

void _updateTableSizeWithFixedTotalWidth() {
  // Ensure the total width of the table remains constant
  double totalColumnWidth = columnWidths.reduce((a, b) => a + b);
  double fixedTableWidth = tableWidth;

  if (totalColumnWidth != fixedTableWidth) {
    // Adjust the last column to make sure the total width remains constant
    double adjustment = fixedTableWidth - totalColumnWidth;
    columnWidths[columnWidths.length - 1] += adjustment;
  }
}

void _updateTableSizeWithFixedTotalHeight() {
  // Ensure the total height of the table remains constant
  double totalRowHeight = rowHeights.reduce((a, b) => a + b);
  double fixedTableHeight = tableHeight;  

  if (totalRowHeight != fixedTableHeight) {
    // Adjust the last row to make sure the total height remains constant
    double adjustment = fixedTableHeight - totalRowHeight;
    rowHeights[rowHeights.length - 1] += adjustment;
  }
}


    @override
    Widget build(BuildContext context) {

    return Scaffold(
    body: Stack(
    children: [
      // Positioned for the draggable and resizable table
      Positioned(
        left: tablePosition.dx,
        top: tablePosition.dy,
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
                    width: columnWidths.isNotEmpty? columnWidths.reduce((a, b) => a + b): numCols * defaultCellWidth,
                    height: rowHeights.isNotEmpty? rowHeights.reduce((a, b) => a + b): numRows * defaultCellHeight,
                     child: Stack(
                      children: [
                        // Cell Rendering
                        for (int row = 0; row < numRows; row++)
                          for (int col = 0; col < numCols; col++)
                              Positioned(
                                left: columnWidths.sublist(0, col).fold(0.0, (sum, w) => (sum ?? 0) + (w)),
                                top: rowHeights.sublist(0, row).fold(0.0,(sum, h) => (sum ?? 0) + (h)),
                                width: columnWidths.sublist(col, col + cells[row][col].colSpan).fold(0.0, (sum,w) =>(sum ?? 0) + (w)),
                                height:  rowHeights.sublist(row, row + cells[row][col].rowSpan).fold(0.0, (sum, h) => (sum ?? 0) + (h)),
                                child: GestureDetector(
                                  onDoubleTap: () {
                                    _showCellOptionsDialog(row, col);
                                  },
                               
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cells[row][col].color,
                                      ),
                                      child: DottedBorder(
                                        color: Colors.black,
                                        strokeWidth: 1,
                                        dashPattern: const [6,3,6,3],
                                        child: TextField(
                                          onTap: ()=> _onCellTap(row, col),
                                          controller: cells[row][col].controller,
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            hintText: "Add Data",
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                                 // Create resize handlers for the selected column
                              if (selectedColumn != null) ...[
                                // Handler for the selected column
                                if (selectedColumn! < columnWidths.length - 1) // Exclude the last column from having a resize handler
                                  Positioned(
                                    left: columnWidths.sublist(0, selectedColumn! + 1).fold(0.0, (sum, w) => sum + w) - 10,
                                    top: 0,
                                    child: GestureDetector(
                                      onPanUpdate: (details) => _resizeColumn(selectedColumn!, details),
                                      onPanEnd: (details) {
                                        // setState(() {
                                        //   selectedColumn = null; // Reset selected column after resizing
                                        // });
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
                                  ),

                                // Handler for the column beside the selected column (previous or next)
                                if (selectedColumn! > 0)
                                  Positioned(
                                    left: columnWidths.sublist(0, selectedColumn!).fold(0.0, (sum, w) => sum + w) - 10,
                                    top: 0,
                                    child: GestureDetector(
                                      onPanUpdate: (details) => _resizeColumn(selectedColumn! - 1, details),
                                      onPanEnd: (details) {
                                        // setState(() {
                                        //   selectedColumn = null; // Reset selected column after resizing
                                        // });
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
                                  ),
                              ],

                              // Create resize handlers for the selected row
                              if (selectedRow != null) ...[
                                // Handler for the selected row
                                if (selectedRow! < rowHeights.length - 1) // Exclude the last row from having a resize handler
                                  Positioned(
                                    left: -10,
                                    top: rowHeights.sublist(0, selectedRow! + 1).fold(0.0, (sum, h) => sum + h) - 10,
                                    child: GestureDetector(
                                      onPanUpdate: (details) => _resizeRow(selectedRow!, details),
                                      onPanEnd: (details) {
                                        // setState(() {
                                        //   selectedRow = null; // Reset selected row after resizing
                                        // });
                                      },
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
                                  ),

                                // Handler for the row above the selected row
                                if (selectedRow! > 0)
                                  Positioned(
                                    left: -10,
                                    top: rowHeights.sublist(0, selectedRow!).fold(0.0, (sum, h) => sum + h) - 10,
                                    child: GestureDetector(
                                      onPanUpdate: (details) => _resizeRow(selectedRow! - 1, details),
                                      onPanEnd: (details) {
                                        // setState(() {
                                        //   selectedRow = null; // Reset selected row after resizing
                                        // });
                                      },
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
                                  ),
 
                              ],
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
  }
 

  class Cell {
  String content;
  int colSpan;
  int rowSpan;
  TextEditingController controller;
  Color color;

  Cell({
    required this.content,
    this.colSpan = 1,
    this.rowSpan = 1,
    required this.controller,
    this.color = Colors.white,
  });

  }
  

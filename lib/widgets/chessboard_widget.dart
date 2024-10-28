import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart'; // Import provider for state management
import '../models/game_state.dart'; // Import the game state management class

class ChessboardWidget extends StatefulWidget {
  const ChessboardWidget({super.key});

  @override
  ChessboardWidgetState createState() => ChessboardWidgetState();
}

class ChessboardWidgetState extends State<ChessboardWidget> {
  static const int boardSize = 8;
  final Color lightSquareColor = Color(0xFFDDB88C);
  final Color darkSquareColor = Color(0xFF8B4513);
  final Color backgroundColor = Colors.grey;

  // Mocking a chess piece array for demonstration
  final List<String?> pieces = [
    'bR', 'bN', 'bB', 'bQ', 'bK', 'bB', 'bN', 'bR', // 8th rank
    'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP', // 7th rank
    null, null, null, null, null, null, null, null, // 6th rank
    null, null, null, null, null, null, null, null, // 5th rank
    null, null, null, null, null, null, null, null, // 4th rank
    null, null, null, null, null, null, null, null, // 3rd rank
    'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP', // 2nd rank
    'wR', 'wN', 'wB', 'wQ', 'wK', 'wB', 'wN', 'wR', // 1st rank
  ];

  int? selectedPieceIndex; // To keep track of the selected piece index
  final Logger logger = Logger(); // Create a logger instance

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions based on the screen size
    final double availableHeight = MediaQuery.of(context).size.height * 0.75; // 75% of the height
    final double availableWidth = MediaQuery.of(context).size.height * 0.75; // 80% of the width
    final double cellSize = availableHeight / (boardSize + 2); // Adjusted for proper sizing
    final double boardDimension = cellSize * boardSize; // Total dimension of the chessboard

    return Center(
      child: SizedBox(
        width: availableWidth,
        height: availableHeight,
        child: Stack(
          alignment: Alignment.center, // Center the Stack
          children: [
            // Background 10x10 grid for coordinates
            GridView.builder(
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              shrinkWrap: true, // Adjusts GridView to fit its content
              itemCount: 100, // 10x10 grid including coordinates
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                childAspectRatio: 1.0, // Make each cell square
              ),
              itemBuilder: (context, index) {
                final row = index ~/ 10;
                final col = index % 10;

                // Top and bottom row (A-H)
                if (row == 0 && col > 0 && col < 9) {
                  return _buildLabelCell(String.fromCharCode(64 + col)); // A, B, C, ..., H
                } else if (row == 9 && col > 0 && col < 9) {
                  return _buildLabelCell(String.fromCharCode(64 + col)); // A, B, C, ..., H
                }

                // Left and right column (1-8)
                if (col == 0 && row > 0 && row < 9) {
                  return _buildLabelCell((9 - row).toString()); // 8, 7, ..., 1
                } else if (col == 9 && row > 0 && row < 9) {
                  return _buildLabelCell((9 - row).toString()); // 8, 7, ..., 1
                }

                // Empty cell background
                return Container(color: backgroundColor);
              },
            ),
            // 8x8 chessboard grid on top of the 10x10 grid
            Positioned(
              top: cellSize, // Align the chessboard below the label row
              left: cellSize, // Align the chessboard to the right of the label column
              width: boardDimension, // Chessboard takes full width
              height: boardDimension, // Chessboard takes full height
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 64,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                  childAspectRatio: 1.0, // Make each square square
                ),
                itemBuilder: (context, index) {
                  final row = index ~/ boardSize;
                  final col = index % boardSize;
                  final isLightSquare = (row + col) % 2 == 0;

                  // Get the piece at this position
                  String? piece = pieces[index];

                  // Check if the current cell is the selected piece
                  bool isSelected = selectedPieceIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedPieceIndex == index) {
                          // Deselect if already selected
                          selectedPieceIndex = null;
                        } else {
                          // Select the new piece
                          selectedPieceIndex = index;
                          // Switch the turn when a piece is selected
                          context.read<GameState>().switchTurn();
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent.withOpacity(0.5)
                            : (isLightSquare ? lightSquareColor : darkSquareColor),
                        border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
                      ),
                      child: piece != null
                          ? Image.asset(
                              'assets/images/${piece.startsWith('b') ? 'b' : 'w'}${piece[1].toUpperCase()}.png',
                              fit: BoxFit.contain,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build label cell with centered text
  Widget _buildLabelCell(String label) {
    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

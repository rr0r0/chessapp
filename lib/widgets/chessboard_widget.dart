import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/move.dart'; // Import Move class for handling moves

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

  final List<String?> pieces = [
    'bR', 'bN', 'bB', 'bQ', 'bK', 'bB', 'bN', 'bR',
    'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP', 'bP',
    null, null, null, null, null, null, null, null,
    null, null, null, null, null, null, null, null,
    null, null, null, null, null, null, null, null,
    null, null, null, null, null, null, null, null,
    'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP', 'wP',
    'wR', 'wN', 'wB', 'wQ', 'wK', 'wB', 'wN', 'wR',
  ];

  int? selectedPieceIndex;
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    final double availableHeight = MediaQuery.of(context).size.height * 0.75;
    final double availableWidth = MediaQuery.of(context).size.height * 0.75;
    final double cellSize = availableHeight / (boardSize + 2);
    final double boardDimension = cellSize * boardSize;

    return Center(
      child: SizedBox(
        width: availableWidth,
        height: availableHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background 10x10 grid for coordinates
            _buildLabelGrid(),
            // 8x8 chessboard grid on top of the 10x10 grid
            Positioned(
              top: cellSize, // Align the chessboard below the label row
              left: cellSize, // Align the chessboard to the right of the label column
              width: boardDimension,
              height: boardDimension,
              child: _buildChessboard(cellSize, boardDimension),
            ),
          ],
        ),
      ),
    );
  }

  // Create label grid
  Widget _buildLabelGrid() {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 100,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 10;
        final col = index % 10;

        if (row == 0 && col > 0 && col < 9) {
          return _buildLabelCell(String.fromCharCode(64 + col)); // A-H
        } else if (row == 9 && col > 0 && col < 9) {
          return _buildLabelCell(String.fromCharCode(64 + col)); // A-H
        }

        if (col == 0 && row > 0 && row < 9) {
          return _buildLabelCell((9 - row).toString()); // 8-1
        } else if (col == 9 && row > 0 && row < 9) {
          return _buildLabelCell((9 - row).toString()); // 8-1
        }

        return Container(color: backgroundColor);
      },
    );
  }

  // Create chessboard
  Widget _buildChessboard(double cellSize, double boardDimension) {
    return SizedBox(
      width: boardDimension,
      height: boardDimension,
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: 64,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: boardSize,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ boardSize;
          final col = index % boardSize;
          final isLightSquare = (row + col) % 2 == 0;
          String? piece = pieces[index];
          bool isSelected = selectedPieceIndex == index;

          return GestureDetector(
onTap: () {
  setState(() {
    if (selectedPieceIndex == null) {
      // Select the piece if one is tapped
      if (piece != null) {
        selectedPieceIndex = index;
      }
    } else {
      final selectedPiece = pieces[selectedPieceIndex!];

      // Check if target piece is of the same color
      if (piece != null && selectedPiece != null && piece[0] == selectedPiece[0]) {
        // If the selected piece and target piece are the same color, deselect
        selectedPieceIndex = null;
      } else {
        // Check if the move is valid
        if (selectedPiece != null &&
            context.read<GameState>().chessGame.isValidMove(
                selectedPiece, selectedPieceIndex!, index)) {

          // Capture piece if applicable
          String? capturedPiece = pieces[index];
          if (capturedPiece != null) {
            context.read<GameState>().addCapturedPiece(
                _getPieceName(capturedPiece));
          }

          // Generate move message
          String moveMessage;
          if (capturedPiece != null) {
            moveMessage = "${_getPieceName(selectedPiece)} captures ${_getPieceName(capturedPiece)} at ${_getPosition(index)} from ${_getPosition(selectedPieceIndex!)}";
          } else {
            moveMessage = "${_getPieceName(selectedPiece)} moves from ${_getPosition(selectedPieceIndex!)} to ${_getPosition(index)}";
          }

          // Log move or capture
          logger.d(moveMessage);

          // Move the piece
          pieces[index] = selectedPiece;
          pieces[selectedPieceIndex!] = null;

          // Add the move to the game state
          context.read<GameState>().addMove(
            Move(
              _getPieceName(selectedPiece),
              _getPosition(selectedPieceIndex!),
              _getPosition(index),
              isCapture: capturedPiece != null,
              description: moveMessage,
            ),
          );

          // Switch turn after move
          context.read<GameState>().switchTurn();
        }

        // Reset selection after any move or capture attempt
        selectedPieceIndex = null;
      }
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
    );
  }

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

  String _getPieceName(String? piece) {
    if (piece == null) return '';
    
    String color = piece.startsWith('b') ? 'Black' : 'White';
    String pieceType;

    switch (piece[1]) {
      case 'P':
        pieceType = 'Pawn';
        break;
      case 'R':
        pieceType = 'Rook';
        break;
      case 'N':
        pieceType = 'Knight';
        break;
      case 'B':
        pieceType = 'Bishop';
        break;
      case 'Q':
        pieceType = 'Queen';
        break;
      case 'K':
        pieceType = 'King';
        break;
      default:
        pieceType = 'Unknown';
    }

    return '$color $pieceType';
  }

  String _getPosition(int index) {
    int row = (7 - (index ~/ boardSize));
    int col = (index % boardSize);
    String columnLabel = String.fromCharCode('a'.codeUnitAt(0) + col);
    return '$columnLabel${row + 1}';
  }
}

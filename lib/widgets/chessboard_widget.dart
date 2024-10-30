import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/move.dart';

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
            _buildLabelGrid(),
            Positioned(
              top: cellSize,
              left: cellSize,
              width: boardDimension,
              height: boardDimension,
              child: _buildChessboard(cellSize, boardDimension),
            ),
          ],
        ),
      ),
    );
  }

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
        selectedPieceIndex = index; // Highlight the selected piece
        logger.d('Selected piece: ${_getPieceName(piece)} at ${_getPosition(selectedPieceIndex!)}');
      }
    } else {
      final selectedPiece = pieces[selectedPieceIndex!];

      // Check if selected piece is a King and if castling is possible
      if (selectedPiece != null && selectedPiece[1].toUpperCase() == 'K') {
        bool isWhite = selectedPiece[0] == 'w';
        String color = isWhite ? 'White' : 'Black';

        if (context.read<GameState>().chessGame.canCastle('KingSide', color) &&
            index == (selectedPieceIndex! + 2) && selectedPieceIndex! <= 61) {
          logger.d('$color KingSide castling attempt detected');
          context.read<GameState>().handleCastling('KingSide');
          logger.d('Executed KingSide castling for $color');
          selectedPieceIndex = null;
          return;
        } else if (context.read<GameState>().chessGame.canCastle('QueenSide', color) &&
                   index == (selectedPieceIndex! - 2) && selectedPieceIndex! >= 2) {
          logger.d('$color QueenSide castling attempt detected');
          context.read<GameState>().handleCastling('QueenSide');
          logger.d('Executed QueenSide castling for $color');
          selectedPieceIndex = null;
          return;
        } else {
          logger.d('Invalid castling move attempted for $color King to index $index');
        }
      }

      // If target piece is of the same color, deselect the selected piece
      if (piece != null && selectedPiece != null && piece[0] == selectedPiece[0]) {
        logger.d('Deselected piece: ${_getPieceName(selectedPiece)} at ${_getPosition(selectedPieceIndex!)}');
        selectedPieceIndex = null;
      } else {
        // Validate move for standard piece movement
        if (selectedPiece != null && context.read<GameState>().chessGame.isValidMove(selectedPiece, selectedPieceIndex!, index)) {

          // Ensure the index is valid
          if (index < 0 || index >= 64) {
            logger.d("Attempted to move to an invalid index: $index");
            selectedPieceIndex = null;
            return;
          }

          // Print moving information for debugging
          logger.d("Moving ${_getPieceName(selectedPiece)} from ${_getPosition(selectedPieceIndex!)} to ${_getPosition(index)}");

          // Capture piece if applicable
          String? capturedPiece = pieces[index];
          if (capturedPiece != null) {
            logger.d('Captured piece: ${_getPieceName(capturedPiece)} at ${_getPosition(index)}');
            context.read<GameState>().addCapturedPiece(_getPieceName(capturedPiece));
          }

          // Move the piece
          pieces[index] = selectedPiece; // Place the selected piece in the new position
          pieces[selectedPieceIndex!] = null; // Remove it from the old position

          // Log board state
          logger.d('Moved piece: ${_getPieceName(selectedPiece)}');
          logger.d('Board state: $pieces');

          // Update moved status for the piece
          context.read<GameState>().chessGame.updateMovedStatus(selectedPiece);

          // Add the move to the game state
          context.read<GameState>().addMove(
            Move(
              _getPieceName(selectedPiece),
              _getPosition(selectedPieceIndex!),
              _getPosition(index),
              isCapture: capturedPiece != null,
              description: '${_getPieceName(selectedPiece)} moves from ${_getPosition(selectedPieceIndex!)} to ${_getPosition(index)}'
             '${capturedPiece != null ? " capturing ${_getPieceName(capturedPiece)}" : ""}'
             ),
          );

          // Switch turn after move
          context.read<GameState>().switchTurn();
        } else {
          logger.d('Invalid move attempted for ${_getPieceName(selectedPiece)} to index $index');
        }

        // Reset selection after any move or capture attempt
        selectedPieceIndex = null;
      }
    }
  });
}
,
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

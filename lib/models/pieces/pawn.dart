import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/chessboard.dart';

class Pawn extends Piece {
  final Position? initialPosition;
  bool _hasMovedTwoSquares = false;
  int _moveCount = 0;

  Pawn({required super.color, this.initialPosition});

  void setHasMovedTwoSquares(bool value) => _hasMovedTwoSquares = value;
  bool get hasMovedTwoSquares => _hasMovedTwoSquares;

  void incrementMoveCount() => _moveCount++;
  int get moveCount => _moveCount;

  @override
  bool hasMoved(Chessboard board) {
    // Implement logic to check if the rook has moved already
    return false;
  }

  @override
  bool canMoveTo(Chessboard board, Position to) {
    if (to.row < 0 || to.row > 7 || to.col < 0 || to.col > 7) {
      return false; // Position is out of bounds
    }
    final fromRow = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[fromRow].indexOf(this);
    final from = Position(row: fromRow, col: fromCol);
    final direction = color == PieceColor.white ? 1 : -1;

    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;

    // Regular move
    if (color == PieceColor.white && colDiff == 0 && rowDiff == 1) {
      return board.board[to.row][to.col] == null;
    } else if (color == PieceColor.black &&
        from.col == to.col &&
        rowDiff == -1) {
      return board.board[to.row][to.col] == null;
    }

    // Double move
    if (color == PieceColor.white &&
        from.row == 1 &&
        rowDiff == 2 &&
        colDiff == 0) {
      return board.board[2][from.col] == null &&
          board.board[3][from.col] == null;
    }

    if (color == PieceColor.black &&
        from.row == 6 &&
        rowDiff == -2 &&
        colDiff == 0) {
      return board.board[4][from.col] == null &&
          board.board[5][from.col] == null; // Initial move (black)
    }

    if (rowDiff == direction && (colDiff == 1 || colDiff == -1)) {
      final targetPiece = board.board[to.row][to.col];
      return targetPiece != null && targetPiece.color != color; // Capture
    }

    // En passant
    if ((color == PieceColor.white && rowDiff == 1) ||
        (color == PieceColor.black && rowDiff == -1)) {
      if (colDiff == 1 || colDiff == -1) {
        // Check for En Passant conditions
        if (board.isSquareAttacked(
                    to,
                    color
                        .opposite) && // Check if square is under attack by opponent
                to.col == from.col + 1 ||
            to.col == from.col - 1) {
          // Only adjacent columns
          final oppositeColorPawn = board.board[from.row][to.col];
          if (oppositeColorPawn is Pawn &&
              oppositeColorPawn.color != color &&
              oppositeColorPawn.moveCount == 1 &&
              oppositeColorPawn.hasMovedTwoSquares) {
            final lastMove = board.moveHistory.last;
            if (lastMove.to.row == from.row &&
                lastMove.to.col == to.col &&
                (lastMove.from.row - lastMove.to.row).abs() == 2) {
              // Additional check to ensure En Passant is only allowed on the next move
              if (board.moveHistory.length == 1 ||
                  (board.moveHistory.length > 1 &&
                      board.moveHistory[board.moveHistory.length - 2].to.row ==
                          lastMove.from.row)) {
                return true; // En Passant is valid under these conditions
              }
            }
          }
        }
      }
    }

    return false; // Invalid move
  }
}

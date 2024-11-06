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
    return _moveCount > 0;
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
    final startingRow = color == PieceColor.white ? 1 : 6;
    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;

    // Regular move
    if (colDiff == 0 && rowDiff == direction) {
      return board.board[to.row][to.col] == null;
    }

    // Double move
    if (colDiff == 0 && rowDiff == 2 * direction && from.row == startingRow) {
      return board.board[from.row + direction][from.col] == null &&
          board.board[to.row][to.col] == null;
    }

    // Diagonal move
    if (rowDiff == direction && (colDiff == 1 || colDiff == -1)) {
      final targetPiece = board.board[to.row][to.col];

      // Regular diagonal capture
      if (targetPiece != null) {
        return targetPiece.color != color;
      }

      // En passant capture
      else if (from.row == startingRow + 3 * direction) {
        final enPassantTarget = board.board[to.row - direction][to.col];
        final lastMove =
            board.moveHistory.isNotEmpty ? board.moveHistory.last : null;

        // Ensure en passant target exists, is a pawn, is of opposite color,
        // and the last move was a double-square move by that pawn
        if (lastMove != null &&
            enPassantTarget != null &&
            enPassantTarget.color != color &&
            enPassantTarget is Pawn &&
            (lastMove.to.row - lastMove.from.row).abs() == 2 &&
            lastMove.to.row == to.row - direction &&
            lastMove.to.col == to.col) {
          // All en passant conditions are met
          return true;
        }
      }
    }

    return false;
  }
}

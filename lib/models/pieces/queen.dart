import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class Queen extends Piece {
  bool _hasMoved = false;

  Queen({required super.color, required Position initialPosition}) {
    position = initialPosition;
  }

  @override
  bool hasMoved(Chessboard board) {
    return _hasMoved;
  }

  @override
  void setHasMoved(bool value) {
    _hasMoved = value;
  }

  @override
  bool canMoveTo(Chessboard board, Position to) {
    final from = position;
    final rowDiff = to.row - from!.row;
    final colDiff = to.col - from.col;

    if (board.board[to.row][to.col] != null &&
        board.board[to.row][to.col]!.color == color) {
      return false;
    }

    // Check for horizontal movement
    if (rowDiff == 0) {
      // Check if there are any pieces in the way
      for (int i = from.col + (colDiff > 0 ? 1 : -1);
          i != to.col;
          i += (colDiff > 0 ? 1 : -1)) {
        if (board.board[from.row][i] != null) return false;
      }
      return true;
    }

    // Check for vertical movement
    if (colDiff == 0) {
      // Check if there are any pieces in the way
      for (int i = from.row + (rowDiff > 0 ? 1 : -1);
          i != to.row;
          i += (rowDiff > 0 ? 1 : -1)) {
        if (board.board[i][from.col] != null) return false;
      }
      return true;
    }

    // Check for diagonal movement
    if (rowDiff.abs() == colDiff.abs()) {
      // Check if there are any pieces in the way
      for (int i = 1; i < rowDiff.abs(); i++) {
        final row = from.row + (rowDiff > 0 ? i : -i);
        final col = from.col + (colDiff > 0 ? i : -i);
        if (board.board[row][col] != null) return false;
      }
      return true;
    }

    return false;
  }
}

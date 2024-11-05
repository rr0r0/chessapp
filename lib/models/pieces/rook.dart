import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class Rook extends Piece {
  @override
  Position? position;
  bool _hasMoved = false;

  Rook({required super.color, required Position initialPosition}) {
    position = initialPosition; // <--- Ensure position is set initially
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
    if (to.row < 0 || to.row > 7 || to.col < 0 || to.col > 7) {
      return false; // Position is out of bounds
    }
    final from = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[from].indexOf(this);
    final rowDiff = to.row - from;
    final colDiff = to.col - fromCol;

    if (rowDiff == 0 || colDiff == 0) {
      int step = rowDiff != 0 ? rowDiff.abs() : colDiff.abs();
      int rowStep = rowDiff != 0 ? rowDiff.sign : 0;
      int colStep = colDiff != 0 ? colDiff.sign : 0;

      for (int i = 1; i < step; i++) {
        if (board.board[from + rowStep * i][fromCol + colStep * i] != null) {
          return false; // Path is blocked
        }
      }

      return board.board[to.row][to.col] == null ||
          board.board[to.row][to.col]!.color != color;
    }

    return false; // Invalid move
  }
}

import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class Bishop extends Piece {
  Bishop({required super.color});

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
    final from = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[from].indexOf(this);
    final rowDiff = to.row - from;
    final colDiff = to.col - fromCol;

    if (rowDiff.abs() == colDiff.abs()) {
      int step = rowDiff.abs();
      int rowStep = rowDiff.sign;
      int colStep = colDiff.sign;

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

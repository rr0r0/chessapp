import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class Bishop extends Piece {
  Bishop({required super.color});

  @override
  bool canMoveTo(Chessboard board, Position to) {
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

      return board.board[to.row][to.col] == null || board.board[to.row][to.col]!.color != color;
    }

    return false; // Invalid move
  }
}
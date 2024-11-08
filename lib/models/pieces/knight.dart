import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class Knight extends Piece {
  Knight({required super.color, required Position initialPosition}) {
    position = initialPosition;
  }

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

    final possibleMoves = [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2]
    ];

    return possibleMoves
            .any((move) => rowDiff == move[0] && colDiff == move[1]) &&
        (board.board[to.row][to.col] == null ||
            board.board[to.row][to.col]!.color != color);
  }
}

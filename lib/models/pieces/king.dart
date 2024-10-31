import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

class King extends Piece {
  King({required super.color});

  @override
  bool canMoveTo(Chessboard board, Position to) {
    final from = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[from].indexOf(this);
    final rowDiff = (to.row - from).abs();
    final colDiff = (to.col - fromCol).abs();

    return rowDiff <= 1 && colDiff <= 1;
  }
}
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/utils/constants.dart';


class GameService {
  final Chessboard board;
  Color currentTurn = Color.white;

  GameService({required this.board});

  bool makeMove(Move move) {
    currentTurn = currentTurn == Color.white ? Color.black : Color.white;
    return board.movePiece(move);
  }
  // Actually check for turn to do move
  /* bool makeMove(Move move) {
    if (isMoveValid(move)) {
      board.movePiece(move);
      currentTurn = currentTurn == Color.white ? Color.black : Color.white;
      return true;
    }
    return false;
  } */

  bool isMoveValid(Move move) {
    return board.isValidMove(move);
  }
}
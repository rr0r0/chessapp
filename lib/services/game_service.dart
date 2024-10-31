import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/move.dart';

class GameService {
  final Chessboard board;

  GameService({required this.board});

  bool makeMove(Move move) {
    return board.movePiece(move);
  }

  bool isMoveValid(Move move) {
    return board.isValidMove(move);
  }
}
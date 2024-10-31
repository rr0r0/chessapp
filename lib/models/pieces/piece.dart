import 'package:chess/chess.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

enum PieceColor { white, black }

abstract class Piece {
  final PieceColor color;

  Piece({required this.color});

  bool canMoveTo(Chessboard board, Position to);

   String renderText() {
    final pieceColor = color == PieceColor.white ? 'W' : 'B';
    final pieceType = runtimeType.toString().split('.').last;
    return '$pieceColor $pieceType';
  }
}
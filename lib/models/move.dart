import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/pieces/piece.dart';

class Move {
  final Position from;
  final Position to;

  Move({required this.from, required this.to});

  @override
  String toString() {
    return 'Move(from: $from, to: $to)';
  }

  bool capture = false; 
  Piece? capturedPiece;
}
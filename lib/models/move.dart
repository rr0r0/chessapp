import 'package:chessapp/models/position.dart';

class Move {
  final Position from;
  final Position to;

  Move({required this.from, required this.to});

  @override
  String toString() {
    return 'Move(from: $from, to: $to)';
  }
}
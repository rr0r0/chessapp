import 'package:chessapp/models/position.dart';

Position positionFromNotation(String notation) {
  final col = notation.codeUnitAt(0) - 'a'.codeUnitAt(0);
  final row = 8 - int.parse(notation.substring(1));
  return Position(row: row, col: col);
}
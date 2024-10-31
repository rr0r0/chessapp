import 'package:flutter_test/flutter_test.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/pieces/knight.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

void main() {
  group('Piece Tests', () {
    test('Pawn movement', () {
      final board = Chessboard.initial();
      final pawn = board.board[1][0]!;
      expect(pawn.canMoveTo(board, Position(row: 2, col: 0)), isTrue);
      expect(pawn.canMoveTo(board, Position(row: 3, col: 0)), isFalse);
    });

    test('Knight movement', () {
      final board = Chessboard.initial();
      final knight = Knight(color: PieceColor.white);
      board.board[0][1] = knight;
      expect(knight.canMoveTo(board, Position(row: 2, col: 2)), isTrue);
      expect(knight.canMoveTo(board, Position(row: 1, col: 1)), isFalse);
    });

    // Add more tests for other pieces
  });
}
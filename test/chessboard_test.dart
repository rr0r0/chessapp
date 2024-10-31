// test/chessboard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/pieces/pawn.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/services/game_service.dart';

void main() {
  group('Chessboard Tests', () {
    test('Initial board setup', () {
      final board = Chessboard.initial();
      expect(board.board[1][0], isA<Pawn>());
      expect(board.board[1][0]!.color, equals(PieceColor.white));
      expect(board.board[6][0], isA<Pawn>());
      expect(board.board[6][0]!.color, equals(PieceColor.black));
    });

    test('Move piece', () {
      final board = Chessboard.initial();
      final gameService = GameService(board: board);
      final move = Move(from: Position(row: 1, col: 0), to: Position(row: 2, col: 0));
      expect(gameService.makeMove(move), isTrue);
      expect(board.board[1][0], isNull);
      expect(board.board[2][0], isA<Pawn>());
    });

    test('Invalid move', () {
      final board = Chessboard.initial();
      final gameService = GameService(board: board);
      final move = Move(from: Position(row: 1, col: 0), to: Position(row: 3, col: 0));
      expect(gameService.makeMove(move), isFalse);
    });
  });
}
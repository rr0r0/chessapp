import 'package:flutter/material.dart';
import 'chess_game.dart';
import 'move.dart'; // Ensure this path is correct

class GameState with ChangeNotifier {
  final ChessGame chessGame = ChessGame();
  
  String _currentTurn = 'White';
  String get currentTurn => _currentTurn;

  final List<Move> _moves = [];
  List<Move> get moveHistory => List.unmodifiable(_moves);

  final List<String> _capturedPieces = [];
  List<String> get capturedPieces => List.unmodifiable(_capturedPieces);

  void switchTurn() {
    _currentTurn = (_currentTurn == 'White') ? 'Black' : 'White';
    notifyListeners();
  }

  void addMove(Move move) {
    _moves.add(move);
    notifyListeners();
  }

  void addCapturedPiece(String piece) {
    _capturedPieces.add(piece);
    notifyListeners();
  }

  void reset() {
    chessGame.reset();
    _moves.clear();
    _capturedPieces.clear();
    _currentTurn = 'White';
    notifyListeners();
  }
}

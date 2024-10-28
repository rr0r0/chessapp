import 'package:flutter/material.dart';

class GameState with ChangeNotifier {
  String _currentTurn = 'White';

  String get currentTurn => _currentTurn;

  void switchTurn() {
    if (_currentTurn == 'White') {
      _currentTurn = 'Black';
    } else {
      _currentTurn = 'White';
    }
    notifyListeners(); // Notify listeners about the change
  }
}

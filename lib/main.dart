import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/game_state.dart'; // Import the game state management class
import 'screens/chess_screen.dart'; // Import chess_screen.dart

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: ChessApp(),
    ),
  );
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess App',
      home: ChessScreen(), // Directly use the ChessScreen
    );
  }
}

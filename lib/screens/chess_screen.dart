import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart'; // Import the GameState class
import '../widgets/chessboard_widget.dart'; // Import the chessboard widget

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess Game'),
      ),
      body: Row(
        children: [
          // Left grey area for displaying current turn
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: Consumer<GameState>( // Use Consumer to listen for changes
              builder: (context, gameState, child) {
                return Text(
                  gameState.currentTurn, // Display current turn
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          // Main chessboard area
          Expanded(
            child: ChessboardWidget(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../widgets/chessboard_widget.dart';

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
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: Column(
              children: [
                Expanded(
                  child: Consumer<GameState>(
                    builder: (context, gameState, child) => Center(
                      child: Text(
                        gameState.currentTurn,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Divider(color: Colors.black),
                Expanded(
                  flex: 2,
                  child: Consumer<GameState>(
                    builder: (context, gameState, child) => ListView.builder(
                      itemCount: gameState.moveHistory.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(gameState.moveHistory[index].toString()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: ChessboardWidget()),
        ],
      ),
    );
  }
}

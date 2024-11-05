import 'package:flutter/material.dart';
import 'package:chessapp/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:chessapp/widgets/board_widget.dart';
import 'package:chessapp/models/chessboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameService(board: Chessboard.initial()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Chess Game')),
        body: ChessApp(),
      ),
    );
  }
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenHeight * 0.9; // Chessboard is 90% of window height
    final leftPanelWidth =
        screenWidth * 0.2; // Left panel is 20% of window width
    final labelWidth = boardSize * 0.05; // Labels are 5% of board size
    final chessboardSize = boardSize * 0.9; // Chessboard is 90% of board size

    return Row(
      children: [
        // Left panel
        Container(
          width: leftPanelWidth,
          height: screenHeight,
          color: Colors.grey,
          child: Column(
            children: [
              // Turn Display
              Container(
                height: screenHeight * 0.15,
                color: const Color.fromARGB(255, 152, 206, 250),
                child: Center(
                  child: Text(
                    'Current Turn: ${context.watch<GameService>().currentTurn.name}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              // History movements display
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        context.watch<GameService>().visualMoveHistory.isEmpty
                            ? [Text("No moves yet")]
                            : context
                                .watch<GameService>()
                                .visualMoveHistory
                                .map((move) {
                                return ListTile(
                                  title: Text(move),
                                );
                              }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Board
        SizedBox(
          width: (screenWidth - leftPanelWidth) * 0.8,
          height: (screenWidth - leftPanelWidth) * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height:
                      labelWidth, // Label height is the same as board cell height
                  width: chessboardSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      return SizedBox(
                        width: chessboardSize /
                            8, // Each label cell has the same width as the board cells
                        child: Center(
                          child: Text(
                            String.fromCharCode('A'.codeUnitAt(0) + index),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Column labels and Chessboard
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Column labels
                      SizedBox(
                        width:
                            labelWidth, // Label width is the same as board cell width
                        height: chessboardSize,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Chessboard
                      SizedBox(
                        width: chessboardSize,
                        height: chessboardSize,
                        child: Center(
                          child: ChessBoardWidget(gridSize: chessboardSize),
                        ),
                      ),
                      // Column labels (right side)
                      SizedBox(
                        width:
                            labelWidth, // Label width is the same as board cell width
                        height: chessboardSize,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(8, (index) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height:
                      labelWidth, // Label height is the same as board cell height
                  width: chessboardSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (index) {
                      return SizedBox(
                        width: chessboardSize /
                            8, // Each label cell has the same width as the board cells
                        child: Center(
                          child: Text(
                            String.fromCharCode('A'.codeUnitAt(0) + index),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

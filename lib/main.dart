import 'package:flutter/material.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/services/game_service.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/move.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(ChessApp());

  debugPaintSizeEnabled = true;
  debugPaintBaselinesEnabled = true;
  debugRepaintRainbowEnabled = true;
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  ChessBoardScreenState createState() => ChessBoardScreenState();
}

class ChessBoardScreenState extends State<ChessBoardScreen> {
  late final Chessboard board;
  late final GameService gameService;
  Position? selectedPiece;

  @override
  void initState() {
    super.initState();
    board = Chessboard.initial();
    gameService = GameService(board: board);
  }

  @override
  Widget build(BuildContext context) {
    final double containerHeight = 0.6 * MediaQuery.of(context).size.height;
    final double cellSize = containerHeight / 10;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chess App'),
      ),
      body: Row(
        children: [
          // Display area on the left
          Container(
            width: 0.2 * MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.grey[200],
            child: Column(
              children: [
                Container(
                  height: 0.01 * MediaQuery.of(context).size.height,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Current Turn: ${gameService.currentTurn.name}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 0.75 * MediaQuery.of(context).size.height,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'History',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Chessboard and background grid on the right
          Expanded(
            child: Container(
              width: containerHeight,
              height: containerHeight,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Stack(
                children: [
                  // Background 10x10 grid
                  Table(
                    children: List.generate(10, (row) {
                      return TableRow(
                        children: List.generate(10, (col) {
                          return Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: (row + col) % 2 == 0 ? Colors.grey[100] : Colors.grey[300],
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  // Row and column labels
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Column(
                      children: List.generate(10, (row) {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          alignment: Alignment.center,
                          child: Text(
                            row == 0 ? '' : (9 - row).toString(),
                            style: TextStyle(fontSize: cellSize * 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      children: List.generate(10, (row) {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          alignment: Alignment.center,
                          child: Text(
                            row == 0 ? '' : (9 - row).toString(),
                            style: TextStyle(fontSize: cellSize * 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Row(
                      children: List.generate(10, (col) {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          alignment: Alignment.center,
                          child: Text(
                            col == 0 ? '' : String.fromCharCode('A'.codeUnitAt(0) + col - 1),
                            style: TextStyle(fontSize: cellSize * 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Row(
                      children: List.generate(10, (col) {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          alignment: Alignment.center,
                          child: Text(
                            col == 0 ? '' : String.fromCharCode('A'.codeUnitAt(0) + col - 1),
                            style: TextStyle(fontSize: cellSize * 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
                  // 8x8 chessboard grid
                  
                  Positioned(
                    top: cellSize,
                    left: cellSize,
                    child: Table(
                      children: List.generate(8, (row) {
                        return TableRow(
                          children: List.generate(8, (col) {
                            final position = Position(row: row, col: col);
                            final piece = board.board[row][col];
                            final isHighlighted = selectedPiece != null && (position == selectedPiece || gameService.isMoveValid(Move(from: selectedPiece!, to: position)));

                            return GestureDetector(
                              onTap: () => handleTap(position),
                              child: Container(
                                width: cellSize,
                                height: cellSize,
                                decoration: BoxDecoration(
                                  color: (row + col) % 2 == 0 ? Colors.white : Colors.brown,
                                  border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
                                ),
                                child: piece != null
                                    ? Center(child: Text(renderText(piece)))
                                    : null,
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleTap(Position position) {
    if (selectedPiece != null) {
      final move = Move(from: selectedPiece!, to: position);
      if (gameService.isMoveValid(move)) {
        debugPrint('Moving piece from ${selectedPiece.toString()} to ${position.toString()}');
        gameService.makeMove(move);
        setState(() {
          selectedPiece = null;
        });
      } else if (selectedPiece.toString() == position.toString()){
        debugPrint('Unselected piece');
        setState(() {
          selectedPiece = null;
        });
      }
    } else {
      final piece = board.board[position.row][position.col];
      if (piece != null) {
        debugPrint('Selected piece ${piece.runtimeType} ${piece.color} at ${position.toString()}');
        setState(() {
          selectedPiece = position;
        });
      } else {
        debugPrint('Invalid move from ${selectedPiece.toString()} to ${position.toString()}');
      }
    }
  }

  String renderText(Piece piece) {
    return piece.renderText();
  }
}
		
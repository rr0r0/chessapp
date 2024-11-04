import 'package:flutter/material.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/services/game_service.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:provider/provider.dart';

class ChessBoardWidget extends StatelessWidget {
  final double gridSize;

  const ChessBoardWidget({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final double cellSize = gridSize / 8;

    return Consumer<GameService>(
      builder: (context, gameService, child) {
        return Container(
          width: gridSize,
          height: gridSize,
          padding: const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Table(
            children: List.generate(8, (row) {
              return TableRow(
                children: List.generate(8, (col) {
                  final position = Position(row: row, col: col);

                  return GestureDetector(
                    onTap: () => gameService.handleTap(position),
                    child: Container(
                      width: cellSize,
                      height: cellSize,
                      decoration: BoxDecoration(
                        color: ((row + col) % 2 == 1)
                            ? const Color.fromARGB(
                                255, 240, 217, 181) // Light square color
                            : const Color.fromARGB(
                                255, 181, 136, 99), // Dark square color
                        border: gameService.selectedPiece != null &&
                                gameService.currentBoard.isValidMove(Move(
                                    from: gameService.selectedPiece!,
                                    to: position))
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: gameService.currentBoard.board[row][col] != null
                          ? Stack(
                              children: [
                                Center(
                                  child: Image.asset(
                                    'images/${gameService.currentBoard.board[row][col]!.renderImage()}',
                                    width: cellSize * 0.8,
                                    height: cellSize * 0.8, // Adjusted height
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ChessBoard extends StatefulWidget {
  final double cellSize;
  final Chessboard chessboard;
  final GameService gameService;

  const _ChessBoard({
    required this.cellSize,
    required this.chessboard,
    required this.gameService,
  });

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<_ChessBoard> {
  Position? selectedPiece;

  void handleTap(Position position) {
    context.read<GameService>().handleTap(position);
  }

  String renderText(Piece piece) {
    return piece.renderText();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.cellSize * 8,
      height: widget.cellSize * 8,
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Table(
        children: List.generate(8, (row) {
          return TableRow(
            children: List.generate(8, (col) {
              final position = Position(row: row, col: col);
              final isHighlighted =
                  context.watch<GameService>().selectedPiece != null &&
                      (position == context.watch<GameService>().selectedPiece ||
                          widget.gameService.currentBoard.isValidMove(Move(
                              from: context.watch<GameService>().selectedPiece!,
                              to: position)));

              return GestureDetector(
                onTap: () => handleTap(position),
                child: Container(
                  width: widget.cellSize,
                  height: widget.cellSize,
                  decoration: BoxDecoration(
                    color: ((row + col) % 2 == 1)
                        ? const Color.fromARGB(
                            255, 240, 217, 181) // Light square color
                        : const Color.fromARGB(
                            255, 181, 136, 99), // Dark square color
                    border: isHighlighted
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: context.watch<GameService>().currentBoard.board[row]
                              [col] !=
                          null
                      ? Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'images/${context.watch<GameService>().currentBoard.board[row][col]!.renderImage()}',
                                width: widget.cellSize * 0.8,
                                height: widget.cellSize * 0.8,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    context
                                        .watch<GameService>()
                                        .currentBoard
                                        .board[row][col]!
                                        .renderText(),
                                    style: TextStyle(
                                      color: isHighlighted
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

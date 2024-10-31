import 'package:flutter/material.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/services/game_service.dart';
import 'package:chessapp/models/pieces/piece.dart';

class BoardWidget extends StatefulWidget {
  final Chessboard board;
  final GameService gameService;

  const BoardWidget({required Key key, required this.board, required this.gameService}) : super(key: key);

  @override
  BoardWidgetState createState() => BoardWidgetState();
}

class BoardWidgetState extends State<BoardWidget> {
  Position? selectedPiece;

  void handleTap(Position position) {
    if (selectedPiece != null) {
      final move = Move(from: selectedPiece!, to: position);
      if (widget.gameService.isMoveValid(move)) {
        debugPrint('Moving piece from ${selectedPiece.toString()} to ${position.toString()}');
        widget.gameService.makeMove(move);
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
      final piece = widget.board.board[position.row][position.col];
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

  @override
  Widget build(BuildContext context) {
    final double containerHeight = 0.6 * MediaQuery.of(context).size.height;
    final double cellSize = containerHeight / 10;

    return Container(
      width: containerHeight,
      height: containerHeight,
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Table(
        children: List.generate(10, (row) {
          return TableRow(
            children: List.generate(10, (col) {
              if (row == 0 && col > 0 && col < 9) {
                // Column labels
                return Container(
                  width: cellSize,
                  height: cellSize,
                  alignment: Alignment.center,
                  child: Text((col).toString()),
                );
              } else if (col == 0 && row > 0 && row < 9) {
                // Row labels
                return Container(
                  width: cellSize,
                  height: cellSize,
                  alignment: Alignment.center,
                  child: Text(String.fromCharCode('A'.codeUnitAt(0) + row - 1)),
                );
              } else if (row > 0 && row < 9 && col > 0 && col < 9) {
                // Chessboard cells
                final boardRow = row - 1;
                final boardCol = col - 1;
                final position = Position(row: boardRow, col: boardCol);
                final piece = widget.board.board[boardRow][boardCol];
                final isHighlighted = selectedPiece != null && (position == selectedPiece || widget.gameService.isMoveValid(Move(from: selectedPiece!, to: position)));

                return GestureDetector(
                  onTap: () => handleTap(position),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: (boardRow + boardCol) % 2 == 0 ? Colors.white : Colors.brown,
                      border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
                    ),
                    child: piece != null
                        ? Center(child: Text(renderText(piece)))
                        : null,
                  ),
                );
              } else {
                // Empty cells
                return Container(
                  width: cellSize,
                  height: cellSize,
                );
              }
            }),
          );
        }),
      ),
    );
  }
}
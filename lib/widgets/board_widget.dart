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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
      itemCount: 64,
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final position = Position(row: row, col: col);
        final piece = widget.board.board[row][col];
        final isHighlighted = selectedPiece != null && (position == selectedPiece || widget.gameService.isMoveValid(Move(from: selectedPiece!, to: position)));

        return GestureDetector(
          onTap: () => handleTap(position),
          child: Container(
            decoration: BoxDecoration(
              color: (row + col) % 2 == 0 ? Colors.white : Colors.brown,
              border: isHighlighted ? Border.all(color: Colors.blue, width: 2) : null,
            ),
            child: piece != null
                ? Center(child: Text(renderText(piece)))
                : null,
          ),
        );
      },
    );
  }
}
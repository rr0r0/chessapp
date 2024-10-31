import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:flutter/material.dart';

class Pawn extends Piece {
  Pawn({required super.color});

  @override
  bool canMoveTo(Chessboard board, Position to) {
    final fromRow = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[fromRow].indexOf(this);
    final from = Position(row: fromRow, col: fromCol);
    final direction = color == PieceColor.white ? 1 : -1;

    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;
    
    // Regular move
    if (from.col == to.col && rowDiff.abs() == 1) {
      print('Single $color move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return board.board[to.row][to.col] == null;
    }

    // Double move
    if (color == PieceColor.white &&
        from.row == 1 &&
        rowDiff  == 2 &&
        colDiff == 0) {
      print('Double $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');    
      return board.board[5][from.col] == null &&
          board.board[4][from.col] == null;
    }

    if (color == PieceColor.black &&
        from.row == 6 &&
        rowDiff == -2 &&
        colDiff == 0) {
      
       print('Double $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');    
      return board.board[2][from.col] == null &&
          board.board[3][from.col] == null; // Initial move (black)
    }

    if (rowDiff == direction && (colDiff == 1 || colDiff == -1)) {
      final targetPiece = board.board[to.row][to.col];
       print('Capture $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return targetPiece != null && targetPiece.color != color; // Capture
    }

    return false; // Invalid move
  }
}

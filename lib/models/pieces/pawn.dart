import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:flutter/material.dart';

class Pawn extends Piece {
  Pawn({required super.color});

  @override
  bool hasMoved(Chessboard board) {
    // Implement logic to check if the rook has moved already
    return false;
  }

  @override
  bool canMoveTo(Chessboard board, Position to) {
    if (to.row < 0 || to.row > 7 || to.col < 0 || to.col > 7) {
      return false; // Position is out of bounds
    }
    final fromRow = board.board.indexWhere((row) => row.contains(this));
    final fromCol = board.board[fromRow].indexOf(this);
    final from = Position(row: fromRow, col: fromCol);
    final direction = color == PieceColor.white ? 1 : -1;

    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;

    // Regular move
    if (color == PieceColor.white && colDiff == 0 && rowDiff == 1) {
      debugPrint(
          'Single $color move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return board.board[to.row][to.col] == null;
    } else if (color == PieceColor.black &&
        from.col == to.col &&
        rowDiff == -1) {
      debugPrint(
          'Single $color move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return board.board[to.row][to.col] == null;
    }

    // Double move
    if (color == PieceColor.white &&
        from.row == 1 &&
        rowDiff == 2 &&
        colDiff == 0) {
      debugPrint(
          'Double $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return board.board[2][from.col] == null &&
          board.board[3][from.col] == null;
    }

    if (color == PieceColor.black &&
        from.row == 6 &&
        rowDiff == -2 &&
        colDiff == 0) {
      debugPrint(
          'Double $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return board.board[4][from.col] == null &&
          board.board[5][from.col] == null; // Initial move (black)
    }

    if (rowDiff == direction && (colDiff == 1 || colDiff == -1)) {
      final targetPiece = board.board[to.row][to.col];
      debugPrint(
          'Capture $color  move at: ${from.row}, ${from.col} : ${to.row}, ${to.col}');
      return targetPiece != null && targetPiece.color != color; // Capture
    }

    return false; // Invalid move
  }
}

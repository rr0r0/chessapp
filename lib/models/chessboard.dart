// lib/models/chessboard.dart
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/pieces/pawn.dart';
import 'package:chessapp/models/pieces/rook.dart';
import 'package:chessapp/models/pieces/knight.dart';
import 'package:chessapp/models/pieces/bishop.dart';
import 'package:chessapp/models/pieces/queen.dart';
import 'package:chessapp/models/pieces/king.dart';
import 'package:chessapp/models/move.dart';
import 'package:flutter/material.dart';

class Chessboard {
  final List<List<Piece?>> board;

  Chessboard({required this.board});

  factory Chessboard.initial() {
    final board = List.generate(8, (_) => List<Piece?>.filled(8, null));
    // Place pieces on the board
    for (int i = 0; i < 8; i++) {
      board[1][i] = Pawn(color: PieceColor.white);
      board[6][i] = Pawn(color: PieceColor.black);
    }
    // Place other pieces (rooks, knights, etc.)
    board[0][0] = Rook(color: PieceColor.white);
    board[0][7] = Rook(color: PieceColor.white);
    board[7][0] = Rook(color: PieceColor.black);
    board[7][7] = Rook(color: PieceColor.black);

    board[0][1] = Knight(color: PieceColor.white);
    board[0][6] = Knight(color: PieceColor.white);
    board[7][1] = Knight(color: PieceColor.black);
    board[7][6] = Knight(color: PieceColor.black);

    board[0][2] = Bishop(color: PieceColor.white);
    board[0][5] = Bishop(color: PieceColor.white);
    board[7][2] = Bishop(color: PieceColor.black);
    board[7][5] = Bishop(color: PieceColor.black);

    board[0][3] = Queen(color: PieceColor.white);
    board[7][3] = Queen(color: PieceColor.black);

    board[0][4] = King(color: PieceColor.white);
    board[7][4] = King(color: PieceColor.black);

    return Chessboard(board: board);
  }

  // Method to move a piece
   bool movePiece(Move move) {
    final from = move.from;
    final to = move.to;
    final piece = board[from.row][from.col];
    if (piece == null) {
      debugPrint('No piece at ${from.toString()}');
      return false;
    }
    if (!piece.canMoveTo(this, to)) {
      debugPrint('Move from ${from.toString()} to ${to.toString()} is not valid');
      return false;
    }
    board[to.row][to.col] = piece;
    board[from.row][from.col] = null;
    debugPrint('Moved piece from ${from.toString()} to ${to.toString()}');
    return true;
  }

  // Method to check if a move is valid
  bool isValidMove(Move move) {
    final from = move.from;
    final to = move.to;
    final piece = board[from.row][from.col];
    if (piece == null) {
      debugPrint('No piece at ${from.toString()}');
      return false;
    }

    return piece.canMoveTo(this, to);
  }
}
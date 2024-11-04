// lib/models/chessboard.dart
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/pieces/pawn.dart';
import 'package:chessapp/models/pieces/rook.dart';
import 'package:chessapp/models/pieces/knight.dart';
import 'package:chessapp/models/pieces/bishop.dart';
import 'package:chessapp/models/pieces/queen.dart';
import 'package:chessapp/models/pieces/king.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/models/position.dart';
import 'package:flutter/material.dart';

class Chessboard {
  final List<Move> moveHistory = [];
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

    board[0][4] = King(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 4));
    board[7][4] = King(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 4));

    return Chessboard(board: board);
  }

  // Method to move a piece
  bool movePiece(Move move) {
    final from = move.from;
    final to = move.to;
    final piece = board[from.row][from.col];
    if (piece is King && (to.col - from.col).abs() == 2) {
      final rook = getRook(to, from);
      if (rook != null) {
        final oldRookPosition = rook.position;
        if (oldRookPosition != null) {
          final rookMoveCol = to.col > from.col ? to.col - 1 : to.col + 1;
          board[to.row][rookMoveCol] = rook;
          board[oldRookPosition.row][oldRookPosition.col] = null;
          rook.position = Position(row: to.row, col: rookMoveCol);
        }
      }
      // ignore: unnecessary_cast
      (piece as King).hasMoved; // Update the hasMoved flag
    }
    board[to.row][to.col] = piece;
    board[from.row][from.col] = null;
    if (piece?.position != null) {
      piece?.position = to;
    }
    debugPrint('Moved piece from ${from.toString()} to ${to.toString()}');
    moveHistory.add(move);
    return true;
  }

  Piece? getRook(Position to, Position from) {
    final row = from.row;
    final king = board[from.row][from.col];
    for (int i = 0; i < 8; i++) {
      final piece = board[row][i];
      if (piece is Rook && piece.color == king?.color) {
        if (to.col > from.col && i == 7) {
          print(piece.toString());
          return piece;
        } else if (to.col < from.col && i == 0) {
          print(piece.toString());
          return piece;
        }
      }
    }
    return null;
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

  Piece? getPieceAtPositionBeforeMove(Position position, Move move) {
    // Get the piece at the destination position before the move
    final piece = board[position.row][position.col];

    return piece;
  }

  Chessboard copy() {
    final boardCopy =
        board.map((row) => row.map((piece) => piece).toList()).toList();
    return Chessboard(board: boardCopy);
  }

  bool isSquareAttacked(Position pos, PieceColor attackerColor) {
    for (var row in board) {
      for (var piece in row) {
        if (piece != null && piece.color == attackerColor) {
          if (piece.canMoveTo(this, pos)) return true;
        }
      }
    }
    return false;
  }
}

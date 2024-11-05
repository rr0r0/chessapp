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
      board[1][i] = Pawn(
          color: PieceColor.white, initialPosition: Position(row: 1, col: i));
      board[6][i] = Pawn(
          color: PieceColor.black, initialPosition: Position(row: 6, col: i));
    }
    // Place other pieces (rooks, knights, etc.)
    board[0][0] = Rook(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 0));
    board[0][7] = Rook(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 7));
    board[7][0] = Rook(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 0));
    board[7][7] = Rook(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 7));

    board[0][1] = Knight(color: PieceColor.white);
    board[0][6] = Knight(color: PieceColor.white);
    board[7][1] = Knight(color: PieceColor.black);
    board[7][6] = Knight(color: PieceColor.black);

    board[0][2] = Bishop(color: PieceColor.white);
    board[0][5] = Bishop(color: PieceColor.white);
    board[7][2] = Bishop(color: PieceColor.black);
    board[7][5] = Bishop(color: PieceColor.black);

    board[0][3] = Queen(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 3));
    board[7][3] = Queen(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 3));

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
    if (piece!= null) {
      _handleSpecialMoves(move, piece);
      board[to.row][to.col] = piece;
      board[from.row][from.col] = null;
      if (piece.position!= null) {
        piece.position = to;
      }
      moveHistory.add(move);
      return true;
    }
    return false;
  }

  void _handleSpecialMoves(Move move, Piece piece) {
    if (piece is Pawn && (move.to.col - move.from.col).abs() == 1) {
      _handleEnPassant(move, piece);
    } else if (piece is King && (move.to.col - move.from.col).abs() == 2) {
      _handleCastling(move, piece);
    } else {
      piece.setHasMoved(true); // Update the piece's _hasMoved flag
    }
  }

  void _handleEnPassant(Move move, Piece piece) {
    final fromRow = move.from.row;
    final fromCol = move.from.col;
    final toRow = move.to.row;
    final toCol = move.to.col;
    final direction = piece.color == PieceColor.white? 1 : -1;
    final startingRow = piece.color == PieceColor.white? 1 : 6;

    if (fromRow == startingRow + 3 * direction) {
      final enPassantTarget = board[toRow - direction][toCol];
      final lastMove = moveHistory.isNotEmpty? moveHistory.last : null;

      if (lastMove!= null &&
          enPassantTarget!= null &&
          enPassantTarget.color!= piece.color &&
          enPassantTarget is Pawn &&
          (lastMove.to.row - lastMove.from.row).abs() == 2 &&
          lastMove.to.row == toRow - direction &&
          lastMove.to.col == toCol) {
        // Remove the captured Pawn (En Passant)
        board[lastMove.to.row][lastMove.to.col] = null;
        move.capture = true;
        move.capturedPiece = enPassantTarget;
      }
    }
    piece.setHasMoved(true); // Update the pawn's _hasMoved flag
  }

  void _handleCastling(Move move, Piece piece) {
    final rook = getRook(move.to, move.from);
    if (rook!= null) {
      final oldRookPosition = rook.position;
      if (oldRookPosition!= null) {
        final rookMoveCol =
            move.to.col > move.from.col? move.to.col - 1 : move.to.col + 1;
        board[move.to.row][rookMoveCol] = rook;
        board[oldRookPosition.row][oldRookPosition.col] = null;
        rook.position = Position(
            row: move.to.row, col: rookMoveCol); // Update the rook's position
        rook.setHasMoved(true); // Update the rook's _hasMoved flag
      }
    }
    piece.setHasMoved(true); // Update the king's _hasMoved flag
  }

  Piece? getRook(Position to, Position from) {
    final row = from.row;
    final king = board[from.row][from.col];
    for (int i = 0; i < 8; i++) {
      final piece = board[row][i];
      if (piece is Rook && piece.color == king?.color) {
        if (to.col > from.col && i == 7) {
          return piece;
        } else if (to.col < from.col && i == 0) {
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

    // Check for en passant
    if (piece is Pawn && (move.to.col - move.from.col).abs() == 1) {
      final oppositeColorPawn = board[move.from.row][move.to.col];
      if (oppositeColorPawn is Pawn &&
          oppositeColorPawn.color!= piece.color &&
          oppositeColorPawn.moveCount == 1 &&
          oppositeColorPawn.hasMovedTwoSquares) {
        final lastMove = moveHistory.last;
        if (lastMove.to.row == move.from.row &&
            lastMove.to.col == move.to.col &&
            (lastMove.from.row - lastMove.to.row).abs() == 2) {
          // En passant is valid, even though the destination square is empty
          debugPrint('Possible en passant detected for $piece');
          return true;
        }
      }
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
        if (piece!= null && piece.color == attackerColor) {
          if (piece.canMoveTo(this, pos)) return true;
        }
      }
    }
    return false;
  }
}
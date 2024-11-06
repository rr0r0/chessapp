import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/pieces/pawn.dart';
import 'package:chessapp/models/pieces/rook.dart';
import 'package:chessapp/models/pieces/knight.dart';
import 'package:chessapp/models/pieces/bishop.dart';
import 'package:chessapp/models/pieces/queen.dart';
import 'package:chessapp/models/pieces/king.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/utils/tuple.dart';
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

    board[0][1] = Knight(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 1));
    board[0][6] = Knight(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 6));
    board[7][1] = Knight(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 1));
    board[7][6] = Knight(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 6));

    board[0][2] = Bishop(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 2));
    board[0][5] = Bishop(
        color: PieceColor.white, initialPosition: Position(row: 0, col: 5));
    board[7][2] = Bishop(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 2));
    board[7][5] = Bishop(
        color: PieceColor.black, initialPosition: Position(row: 7, col: 5));

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
    if (piece != null) {
      _handleSpecialMoves(move, piece);
      board[to.row][to.col] = piece;
      board[from.row][from.col] = null;
      if (piece.position != null) {
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
    final toRow = move.to.row;
    final toCol = move.to.col;
    final direction = piece.color == PieceColor.white ? 1 : -1;
    final startingRow = piece.color == PieceColor.white ? 1 : 6;

    if (fromRow == startingRow + 3 * direction) {
      final enPassantTarget = board[toRow - direction][toCol];
      final lastMove = moveHistory.isNotEmpty ? moveHistory.last : null;

      if (lastMove != null &&
          enPassantTarget != null &&
          enPassantTarget.color != piece.color &&
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
    if (rook != null) {
      final oldRookPosition = rook.position;
      print('Old Rook Position: $oldRookPosition');
      if (oldRookPosition != null) {
        // For kingside castling (right): Rook moves from (0,7) to (0,5)
        // For queenside castling (left): Rook moves from (0,0) to (0,4)
        final rookMoveCol = move.to.col > move.from.col ? 5 : 4;
        print('Rook will move to column: $rookMoveCol');

        // Check if the rook's position already matches the target position
        if (oldRookPosition.col != rookMoveCol) {
          // Now move the rook first, before the king
          board[move.to.row][rookMoveCol] = rook;
          board[oldRookPosition.row][oldRookPosition.col] =
              null; // Clear old rook position

          // Update the rook's position
          rook.position = Position(row: move.to.row, col: rookMoveCol);
          rook.setHasMoved(true);

          print(
              'Castling: Moved rook from $oldRookPosition to ${rook.position}');
          print(
              'Board updated: rook at ${rook.position}, king at ${piece.position}');
        } else {
          print('Rook is already at the target position; no move needed.');
        }

        // Now move the king
        piece.position = move.to;
        piece.setHasMoved(true);
      }
    } else {
      print('No rook detected for castling');
    }
  }

  Piece? getRook(Position to, Position from) {
    final row = from.row;
    final color = board[row][from.col]?.color;

    // Find the rook on the same row, either at column 0 or 7
    if (color != null) {
      if (to.col > from.col) {
        // King is castling to the right: look for the rook at (0, 7)
        final rook = board[row][7];
        if (rook is Rook && rook.color == color) {
          return rook;
        }
      } else {
        // King is castling to the left: look for the rook at (0, 0)
        final rook = board[row][0];
        if (rook is Rook && rook.color == color) {
          return rook;
        }
      }
    }

    return null; // Return null if no rook found
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
          oppositeColorPawn.color != piece.color &&
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

  List<Tuple<String, List<Move>>> getValidMovesForAllPieces() {
    final validMoves = <Tuple<String, List<Move>>>[];

    var r = 0;
    var c = 0;
    for (var row in board) {
      //print('row: $row, r: $r');
      c = 0;
      for (var piece in row) {
        //print('col: $c');
        if (piece != null) {
          piece.position ??= Position(row: r, col: c);
          if (piece.position != null) {
            //print('Processing Piece: ${piece.renderText()} at ${piece.position}');
            // Check if both piece and position are non-null
            final piecePosition = piece.position!;
            final validPieceMoves = <Move>[];

            // Check all possible positions on the board for valid moves
            for (int targetRow = 0; targetRow < 8; targetRow++) {
              for (int targetCol = 0; targetCol < 8; targetCol++) {
                final pos = Position(row: targetRow, col: targetCol);
                final tempMove = Move(from: piecePosition, to: pos);
                if (isValidMove(tempMove)) {
                  validPieceMoves.add(tempMove);
                }
              }
            }

            // Only add the piece's moves if there are valid moves to report
            final pieceFormat = piece.renderText();
            if (validPieceMoves.isNotEmpty) {
              validMoves.add(Tuple(pieceFormat, validPieceMoves));
            }
          }
        }
        c++;
      }
      r++;
    }

    return validMoves;
  }

  List<Tuple<String, List<Move>>> getValidMovesForColor(PieceColor color) {
    final allValidMoves = getValidMovesForAllPieces();
    final validMovesForColor = <Tuple<String, List<Move>>>[];
    final colorLetter = color == PieceColor.white ? 'W' : 'B';

    for (final tuple in allValidMoves) {
      if (tuple.item1.startsWith(colorLetter)) {
        validMovesForColor
            .add(tuple); // Add the whole tuple, not all its elements
      }
    }

    return validMovesForColor;
  }
}

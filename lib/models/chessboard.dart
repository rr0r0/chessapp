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
  bool _isCastling = false;

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

  bool movePiece(Move move) {
    final from = move.from;
    final to = move.to;
    final piece = board[from.row][from.col];

    if (piece != null) {
      // Handle any special move logic, such as castling or en passant

      // Move the piece to the new position
      board[to.row][to.col] = piece;

      // Clear the original square only if the piece has moved successfully
      board[from.row][from.col] = null;

      // Update piece position and add to move history
      piece.position = to;
      _handleSpecialMoves(move, piece);
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
    if (_isCastling) {
      return;
    }

    _isCastling = true;
    final rook = getRook(move);

    // Check if rook exists and if it has not moved
    if (rook == null) {
      _isCastling = false;
      return;
    } else if (rook.hasMoved(this)) {
      _isCastling = false;
      return;
    } else if (rook.position!.col == 5 || rook.position!.col == 2) {
      _isCastling = false;
      return;
    }

    final rookOldPosition = rook.position;
    final isKingside = move.to.col > move.from.col;
    final rookNewCol = isKingside ? 5 : 2;


    // Ensure the destination square is empty
    if (board[move.to.row][rookNewCol] != null) {
      _isCastling = false;
      return;
    }

    // Update board with rook's new position and clear old position
    board[move.to.row][rookNewCol] = rook;
    board[rookOldPosition!.row][rookOldPosition.col] = null;

    // Update rook's internal position and mark both rook and king as moved
    rook.position = Position(row: move.to.row, col: rookNewCol);
    rook.setHasMoved(true);
    piece.setHasMoved(true);

    _isCastling = false;
  }

  Piece? getRook(Move kingMove) {
    final from = kingMove.from;
    final to = kingMove.to;
    final row = from.row;
    final color = row == 0 ? PieceColor.white : PieceColor.black;

    // Verify color is non-null and then proceed
    // ignore: unnecessary_null_comparison
    if (color != null) {
      // Determine if this is a kingside or queenside castling attempt
      final isKingside = to.col > from.col;
      final rookCol = isKingside
          ? 7
          : 0; // Kingside rook is typically at column 7, queenside at column 0


      final rook = board[row][rookCol];

      // Ensure the piece at rookCol is a rook of the same color
      if (rook is Rook && rook.color == color) {
        return rook;
      } else {
      }
    } else {
    }

    return null; // Return null if no valid rook found
  }

  bool isValidMove(Move move) {
    final from = move.from;
    final to = move.to;
    final piece = board[from.row][from.col];
    if (piece == null) {
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

  List<Tuple<String, List<Move>>> getValidMovesForAllPieces(Chessboard board) {
    final validMoves = <Tuple<String, List<Move>>>[];
    final simulatedBoard = board.copy();
    final allPieces = _getAllPieces(simulatedBoard);

    for (final piece in allPieces) {
      final validPieceMoves = _getValidMovesForPiece(board, piece);
      if (validPieceMoves.isNotEmpty) {
        validMoves.add(Tuple(piece.renderText(), validPieceMoves));
      }
    }

    return validMoves;
  }

  List<Piece> _getAllPieces(Chessboard board) {
    final allPieces = <Piece>[];
    for (final row in board.board) {
      for (final piece in row) {
        if (piece != null) {
          piece.position ??= _getPosition(piece, board);
          if (piece.position != null) {
            allPieces.add(piece);
          }
        }
      }
    }
    return allPieces;
  }

  List<Move> _getValidMovesForPiece(Chessboard board, Piece piece) {
    final piecePosition = piece.position!;
    final validPieceMoves = <Move>[];

    for (int targetRow = 0; targetRow < 8; targetRow++) {
      for (int targetCol = 0; targetCol < 8; targetCol++) {
        final pos = Position(row: targetRow, col: targetCol);
        final tempMove = Move(from: piecePosition, to: pos);
        if (board.isValidMove(tempMove)) {
          validPieceMoves.add(tempMove);
        }
      }
    }

    return validPieceMoves;
  }

  Position _getPosition(Piece piece, Chessboard board) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        if (board.board[row][col] == piece) {
          return Position(row: row, col: col);
        }
      }
    }
    throw Exception('Piece not found on the board');
  }

  List<Tuple<String, List<Move>>> getValidMovesForColor(
      PieceColor color, Chessboard simulatedBoard) {
    final allValidMoves = getValidMovesForAllPieces(simulatedBoard);
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

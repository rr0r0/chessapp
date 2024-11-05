import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/pieces/rook.dart';

class King extends Piece {
  bool _hasMoved = false;

  King({required super.color, required Position initialPosition}) {
    position = initialPosition;
  }

  @override
  bool hasMoved(Chessboard board) {
    return _hasMoved;
  }

  @override
  void setHasMoved(bool value) {
    _hasMoved = value;
  }

  @override
  bool canMoveTo(Chessboard board, Position to) {
    if (to.row < 0 || to.row > 7 || to.col < 0 || to.col > 7) {
      return false; // Position out of bounds
    }
    if (position == null) return false;

    // Prevent the king from moving to a square occupied by a friendly piece
    if (to == position) return false; // Self-check
    final destinationPiece = board.board[to.row][to.col];
    if (destinationPiece != null && destinationPiece.color == color) {
      return false;
    }

    final from = position!;
    final rowDiff = (to.row - from.row).abs();
    final colDiff = (to.col - from.col).abs();

    if (rowDiff == 0 && colDiff == 2) {
      return canCastle(board, to);
    }

    return rowDiff <= 1 && colDiff <= 1;
  }

  Piece? getRook(Chessboard board, Position to) {
    final row = position!.row;
    final col = to.col > position!.col ? 7 : 0;
    final rook = board.board[row][col];
    return rook is Rook && rook.color == color ? rook : null;
  }

  List<Piece> getBetweenPieces(Chessboard board, Position to) {
    final row = position!.row;
    final startCol = position!.col < to.col ? position!.col + 1 : to.col + 1;
    final endCol = position!.col < to.col ? to.col - 1 : position!.col - 1;

    final pieces = <Piece>[];
    for (int col = startCol; col <= endCol; col++) {
      final piece = board.board[row][col];
      if (piece != null) pieces.add(piece);
    }
    return pieces;
  }

  bool isInCheck(Chessboard board) {
    return board.isSquareAttacked(position!, color.opposite);
  }

  List<Position> getKingPath(Position to) {
    if (to.col > position!.col) {
      return [
        Position(row: position!.row, col: position!.col + 1),
        Position(row: position!.row, col: position!.col + 2),
      ];
    } else {
      return [
        Position(row: position!.row, col: position!.col - 1),
        Position(row: position!.row, col: position!.col - 2),
      ];
    }
  }

  bool canCastle(Chessboard board, Position to) {
    // Check if the king has moved
    if (_hasMoved) {
      return false;
    }

    // Check if the destination square is occupied by a rook
    final rook = getRook(board, to);
    if (rook == null) {
      return false;
    }

    // Check if the king is in check
    if (isInCheck(board)) {
      return false;
    }

    // Check if the king passes through a square that is under attack
    final kingPath = getKingPath(to);
    for (var position in kingPath) {
      if (board.isSquareAttacked(position, color.opposite)) {
        return false;
      }
    }

    // Check if the rook has moved
    if (rook.hasMoved(board)) {
      return false;
    }

    // Check if there are any pieces between the king and the rook
    final betweenPieces = getBetweenPieces(board, to);
    if (betweenPieces.isNotEmpty) {
      return false;
    }

    return true;
  }
}

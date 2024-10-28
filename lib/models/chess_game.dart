import 'package:chess/chess.dart';

class ChessGame {
  final Chess _chess;

  ChessGame() : _chess = Chess();

  // Method to validate moves based on the piece type
  bool isValidMove(String piece, int startIndex, int endIndex) {
    int startRow = startIndex ~/ 8;
    int startCol = startIndex % 8;
    int endRow = endIndex ~/ 8;
    int endCol = endIndex % 8;

    switch (piece[1]) {
      case 'P':
        return _isValidPawnMove(startRow, startCol, endRow, endCol, piece.startsWith('w'));
      case 'R':
        return _isValidRookMove(startRow, startCol, endRow, endCol);
      case 'N':
        return _isValidKnightMove(startRow, startCol, endRow, endCol);
      case 'B':
        return _isValidBishopMove(startRow, startCol, endRow, endCol);
      case 'Q':
        return _isValidQueenMove(startRow, startCol, endRow, endCol);
      case 'K':
        return _isValidKingMove(startRow, startCol, endRow, endCol);
      default:
        return false;
    }
  }

  bool _isValidPawnMove(int startRow, int startCol, int endRow, int endCol, bool isWhite) {
    int direction = isWhite ? -1 : 1;
    int startRowInitial = isWhite ? 6 : 1;

    if (startCol == endCol) {
      if (endRow == startRow + direction) return true;
      if (startRow == startRowInitial && endRow == startRow + 2 * direction) return true;
    } else if ((startCol - endCol).abs() == 1 && endRow == startRow + direction) {
      return true; // Pawn captures diagonally
    }
    return false;
  }

  bool _isValidRookMove(int startRow, int startCol, int endRow, int endCol) {
    return startRow == endRow || startCol == endCol;
  }

  bool _isValidKnightMove(int startRow, int startCol, int endRow, int endCol) {
    return (startRow - endRow).abs() == 2 && (startCol - endCol).abs() == 1 ||
           (startRow - endRow).abs() == 1 && (startCol - endCol).abs() == 2;
  }

  bool _isValidBishopMove(int startRow, int startCol, int endRow, int endCol) {
    return (startRow - endRow).abs() == (startCol - endCol).abs();
  }

  bool _isValidQueenMove(int startRow, int startCol, int endRow, int endCol) {
    return _isValidRookMove(startRow, startCol, endRow, endCol) ||
           _isValidBishopMove(startRow, startCol, endRow, endCol);
  }

  bool _isValidKingMove(int startRow, int startCol, int endRow, int endCol) {
    return (startRow - endRow).abs() <= 1 && (startCol - endCol).abs() <= 1;
  }

    void reset() {
    _chess.reset();
  }
}

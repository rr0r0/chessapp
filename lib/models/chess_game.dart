import 'package:flutter/foundation.dart'; 

class ChessGame extends ChangeNotifier {
  // Assume that you have a method to track piece positions
  final Map<String, bool> pieceMoved = {
    'wK': false, // White King
    'wR1': false, // White Rook on a1
    'wR2': false, // White Rook on h1
    'bK': false, // Black King
    'bR1': false, // Black Rook on a8
    'bR2': false, // Black Rook on h8
  };

  // Sample board representation for demonstration
  final List<String?> pieces = List.filled(64, null); 

  final List<String> _capturedPieces = [];
  List<String> get capturedPieces => List.unmodifiable(_capturedPieces);

  bool isValidMove(String piece, int fromIndex, int toIndex) {
    int fromRow = fromIndex ~/ 8;
    int fromCol = fromIndex % 8;
    int toRow = toIndex ~/ 8;
    int toCol = toIndex % 8;

    // Determine piece type based on the second character, ignoring case
    String type = piece[1].toUpperCase(); // Convert to uppercase to standardize the type check

    // Check if the target square is occupied by a piece of the same color
    String? targetPiece = pieces[toIndex];
    if (targetPiece != null && targetPiece[1].toUpperCase() == type) {
      return false; // Cannot move to a square occupied by the same color piece
    }

    switch (type) {
      case 'K': // King
        return isKingMoveValid(fromRow, fromCol, toRow, toCol);
      case 'R': // Rook
        return isRookMoveValid(fromRow, fromCol, toRow, toCol);
      case 'B': // Bishop
        return isBishopMoveValid(fromRow, fromCol, toRow, toCol);
      case 'N': // Knight
        return isKnightMoveValid(fromRow, fromCol, toRow, toCol);
      case 'Q': // Queen
        return isQueenMoveValid(fromRow, fromCol, toRow, toCol);
      case 'P': // Pawn (both cases handled)
        return isPawnMoveValid(piece, fromRow, fromCol, toRow, toCol);
      default:
        return false; // Invalid piece type
    }
  }

  bool isPawnMoveValid(String piece, int fromRow, int fromCol, int toRow, int toCol) {
    int direction = piece[0] == 'w' ? -1 : 1; // White moves up (1), Black moves down (-1)
    int initialRow = piece[0] == 'w' ? 6 : 1; // Correct initial rows for white and black pawns

    // Check for normal move (one square forward)
    if (toCol == fromCol) {
      // Move one square forward
      if ((toRow - fromRow) == direction) {
        if (pieces[toRow * 8 + toCol] == null) {
          return true; // Valid normal move
        }
      } 
      // Double move from initial position (two squares forward)
      else if ((toRow - fromRow) == 2 * direction) {
        if (fromRow == initialRow) { // Must be the initial row
          if (pieces[(fromRow + direction) * 8 + fromCol] == null && // Check the square in between
              pieces[toRow * 8 + toCol] == null) { // Target square must be empty
            return true; // Valid double move
          }
        }
      }
    }

    // Check for capturing move (diagonal)
    if ((toRow - fromRow) == direction && (toCol - fromCol).abs() == 1) {
      // Ensure the target square contains a piece of the opposite color
      if (pieces[toRow * 8 + toCol] != null &&
          pieces[toRow * 8 + toCol]![0] != piece[0]) {
        return true; // Valid capture move
      }
    }

    return false; // Invalid pawn move
  }

  bool isKingMoveValid(int fromRow, int fromCol, int toRow, int toCol) {
    // King can move one square in any direction
    return (toRow >= fromRow - 1 && toRow <= fromRow + 1) &&
           (toCol >= fromCol - 1 && toCol <= fromCol + 1);
  }

  bool isRookMoveValid(int fromRow, int fromCol, int toRow, int toCol) {
    // Rook can move any number of squares vertically or horizontally
    return (fromRow == toRow || fromCol == toCol);
  }

  bool isBishopMoveValid(int fromRow, int fromCol, int toRow, int toCol) {
    // Check if the move is diagonal
    if ((toRow - fromRow).abs() == (toCol - fromCol).abs()) {
      // Check for pieces in the way
      int rowStep = (toRow - fromRow) > 0 ? 1 : -1;
      int colStep = (toCol - fromCol) > 0 ? 1 : -1;

      int currentRow = fromRow + rowStep;
      int currentCol = fromCol + colStep;

      while (currentRow != toRow && currentCol != toCol) {
        if (pieces[currentRow * 8 + currentCol] != null) {
          return false; // There's a piece in the way
        }
        currentRow += rowStep;
        currentCol += colStep;
      }
      return true; // Valid bishop move
    }
    return false; // Invalid bishop move
  }

  bool isKnightMoveValid(int fromRow, int fromCol, int toRow, int toCol) {
    // Check if the move is an "L" shape
    if ((toRow - fromRow).abs() == 2 && (toCol - fromCol).abs() == 1 ||
        (toRow - fromRow).abs() == 1 && (toCol - fromCol).abs() == 2) {
      return true; // Valid knight move
    }
    return false; // Invalid knight move
  }

  bool isQueenMoveValid(int fromRow, int fromCol, int toRow, int toCol) {
    // Check if the move is valid horizontally, vertically, or diagonally
    if (fromRow == toRow || fromCol == toCol || (toRow - fromRow).abs() == (toCol - fromCol).abs()) {
      // Determine direction
      int rowStep = (toRow - fromRow) == 0 ? 0 : (toRow - fromRow).sign;
      int colStep = (toCol - fromCol) == 0 ? 0 : (toCol - fromCol).sign;

      int currentRow = fromRow + rowStep;
      int currentCol = fromCol + colStep;

      while (currentRow != toRow || currentCol != toCol) {
        if (pieces[currentRow * 8 + currentCol] != null) {
          return false; // There's a piece in the way
        }
        currentRow += rowStep;
        currentCol += colStep;
      }
      return true; // Valid queen move
    }
    return false; // Invalid queen move
  }

  // Update the moved status of pieces
  void updateMovedStatus(String piece) {
    if (piece == 'wK') {
      pieceMoved['wK'] = true;
    } else if (piece == 'wR1') {
      pieceMoved['wR1'] = true;
    } else if (piece == 'wR2') {
      pieceMoved['wR2'] = true;
    } else if (piece == 'bK') {
      pieceMoved['bK'] = true;
    } else if (piece == 'bR1') {
      pieceMoved['bR1'] = true;
    } else if (piece == 'bR2') {
      pieceMoved['bR2'] = true;
    }
  }

  bool canCastle(String side, String color) {
    String king = color == 'White' ? 'wK' : 'bK';
    String rook = side == 'KingSide' ? (color == 'White' ? 'wR2' : 'bR2') : (color == 'White' ? 'wR1' : 'bR1');

    // Log King and Rook status
    print('$color King moved: ${pieceMoved[king]}');
    print('$color Rook moved: ${pieceMoved[rook]}');

    // Check if the king and rook have moved
    if (pieceMoved[king] == false && pieceMoved[rook] == false) {
      // Log additional checks for castling conditions
      print('Castling checks for $color $side:');
      for (int i = 0; i < 3; i++) { // Check all squares between king and rook
        int squareIndex = (side == 'KingSide') ? 62 + i : 58 + i; // Index of the squares between King and Rook
        String? squarePiece = pieces[squareIndex];
        print('Square $squareIndex occupied by: ${squarePiece ?? 'empty'}');

        if (squarePiece != null) {
          print('Cannot castle: Square $squareIndex is occupied.');
          return false; // Cannot castle if any square is occupied
        }
      }

      // Additional checks for check
      if (isUnderAttack(color, king) || isUnderAttack(color, rook)) {
        print('Cannot castle: $color is in check.');
        return false;
      }

      print('Castling is possible for $color $side.');
      return true; // Castling is possible
    }

    print('Cannot castle: $color $side. King or Rook has moved.');
    return false; // Either the king or rook has moved
  }

  void castle(String side, String color) {
    if (canCastle(side, color)) {
      int kingStartIndex = color == 'White' ? 60 : 4; // King start index
      int rookStartIndex = side == 'KingSide' ? (color == 'White' ? 63 : 7) : (color == 'White' ? 56 : 0);
      int kingTargetIndex = side == 'KingSide' ? kingStartIndex + 2 : kingStartIndex - 2; // King target index
      int rookTargetIndex = side == 'KingSide' ? kingTargetIndex - 1 : kingTargetIndex + 1; // Rook target index

      // Move the King and Rook
      pieces[kingTargetIndex] = pieces[kingStartIndex];
      pieces[kingStartIndex] = null; // Empty the old position
      pieces[rookTargetIndex] = pieces[rookStartIndex];
      pieces[rookStartIndex] = null; // Empty the old position

      // Update the moved status
      updateMovedStatus(kingStartIndex == 60 ? 'wK' : 'bK');
      updateMovedStatus(rookStartIndex == 63 ? 'wR2' : (rookStartIndex == 7 ? 'wR1' : 'bR2'));

      print('Castled $color $side. King moved to $kingTargetIndex, Rook moved to $rookTargetIndex.');
      notifyListeners();
    } else {
      print('Castling failed for $color $side.');
    }
  }

  bool isUnderAttack(String color, String piece) {
    // Implement logic to determine if the king is under attack
    return false; // Placeholder for actual implementation
  }

  void reset() {
    // Reset logic for the game state
    pieceMoved['wK'] = false;
    pieceMoved['wR1'] = false;
    pieceMoved['wR2'] = false;
    pieceMoved['bK'] = false;
    pieceMoved['bR1'] = false;
    pieceMoved['bR2'] = false;
  }
}

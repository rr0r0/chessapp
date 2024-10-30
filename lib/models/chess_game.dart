import 'package:flutter/foundation.dart'; 
import 'game_state.dart';
import 'move.dart';


class ChessGame extends ChangeNotifier {
  // Assume that you have a method to track piece positions
  final Map<String, bool> pieceMoved = {
    'wk': false, // White King
    'wr1': false, // White Rook on a1
    'wr2': false, // White Rook on h1
    'bK': false, // Black King
    'bR1': false, // Black Rook on a8
    'bR2': false, // Black Rook on h8
  };

  List<Move> get moveHistory => GameState().moves;

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
    int peassantRow = piece[0] == 'w' ? 3 : 4;

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

    print(moveHistory.toString());
    if (moveHistory.isNotEmpty) {
      print(moveHistory.toString());
    Move lastMove = moveHistory.last;
   if((piece[0] == 'w' && (initialRow - 3*direction) == peassantRow)){
       print(lastMove);
    }else if(((initialRow + 3*direction) ==peassantRow)){
      print(lastMove);
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
    if (piece == 'wk') {
      pieceMoved['wk'] = true;
    } else if (piece == 'wr1') {
      pieceMoved['wr1'] = true;
    } else if (piece == 'wr2') {
      pieceMoved['wr2'] = true;
    } else if (piece == 'bK') {
      pieceMoved['bK'] = true;
    } else if (piece == 'bR1') {
      pieceMoved['bR1'] = true;
    } else if (piece == 'bR2') {
      pieceMoved['bR2'] = true;
    }
  }

  bool canCastle(String side, String color) {
   String king = color == 'White' ? 'wk' : 'bK';
   String rook = side == 'KingSide' ? (color == 'White' ? 'wr2' : 'bR2') : (color == 'White' ? 'wr1' : 'bR1');

   if (!pieceMoved[king]! && !pieceMoved[rook]!) {
      int start = color == 'White' ? 60 : 4;
      int end = side == 'KingSide' ? start + 2 : start - 2;
      
      for (int i = start; i != end; i += side == 'KingSide' ? 1 : -1) {
         if (pieces[i] != null || isUnderAttack(color, 'K')) return false;
      }
      return true;
   }
   return false;
}

void castle(String side, String color) {
   if (canCastle(side, color)) {
      int kingStartIndex = color == 'White' ? 60 : 4;
      int rookStartIndex = side == 'KingSide' ? (color == 'White' ? 63 : 7) : (color == 'White' ? 56 : 0);
      int kingTargetIndex = side == 'KingSide' ? kingStartIndex + 2 : kingStartIndex - 2;
      int rookTargetIndex = side == 'KingSide' ? kingTargetIndex - 1 : kingTargetIndex + 1;

      pieces[kingTargetIndex] = pieces[kingStartIndex];
      pieces[kingStartIndex] = null;
      pieces[rookTargetIndex] = pieces[rookStartIndex];
      pieces[rookStartIndex] = null;

      updateMovedStatus(color == 'White' ? 'wk' : 'bK');
      updateMovedStatus(rookStartIndex == 63 ? 'wr2' : 'wr1');

      notifyListeners();
   }
}


  bool isUnderAttack(String color, String piece) {
    // Implement logic to determine if the king is under attack
    return false; // Placeholder for actual implementation
  }

  void reset() {
    // Reset logic for the game state
    pieceMoved['wk'] = false;
    pieceMoved['wr1'] = false;
    pieceMoved['wr2'] = false;
    pieceMoved['bK'] = false;
    pieceMoved['bR1'] = false;
    pieceMoved['bR2'] = false;
  }
}

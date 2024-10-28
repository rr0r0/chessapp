import 'package:chess/chess.dart';

class ChessGame {
  final Chess _chess;

  ChessGame() : _chess = Chess();

  List<String> get board {
    return List.generate(64, (index) {
      // Get the piece at the current index
      Piece? piece = _chess.board[index];

      if (piece == null) {
        return ''; // No piece on this square
      }

      // Determine prefix based on color
      String colorPrefix = piece.color == Color.WHITE ? 'WHITE' : 'BLACK';
      
      // Map piece types to the correct asset names
      String pieceType = '';
      switch (piece.type) {
        case PieceType.PAWN:
          pieceType = 'p'; 
          break; // Pawn
        case PieceType.ROOK:
          pieceType = 'r'; 
          break; // Rook
        case PieceType.KNIGHT:
          pieceType = 'n'; 
          break; // Knight
        case PieceType.BISHOP:
          pieceType = 'b'; 
          break; // Bishop
        case PieceType.QUEEN:
          pieceType = 'q'; 
          break; // Queen
        case PieceType.KING:
          pieceType = 'k'; 
          break; // King
        default:
          pieceType = ''; // Default case (shouldn't occur)
      }
      
      return '$colorPrefix$pieceType'; // Example: BLACKb, WHITEp, etc.
    });
  }

  void reset() {
    _chess.reset();
  }
}

import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/models/move.dart';

enum PieceColor {
  white,
  black;

  PieceColor get opposite {
    return this == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}

enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

abstract class Piece {
  final PieceColor color;
  Position? position;
  bool _hasMoved = false;

  Position? get pos => position;

  Piece({required this.color});

  bool canMoveTo(Chessboard board, Position to);

  static List<Piece> getPiecesByTypeAndColor(
    PieceColor color,
    PieceType pieceType, {
    required Chessboard board,
  }) {
    List<Piece> matchingPieces = [];

    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        Position position = Position(row: row, col: col);
        Piece? piece = board.getPieceAtPositionBeforeMove(
            position, Move(from: position, to: position));

        if (piece != null &&
            piece.color == color &&
            getPieceType(piece) == pieceType) {
          matchingPieces.add(piece);
        }
      }
    }

    return matchingPieces;
  }

  static PieceType getPieceType(Piece piece) {
    final pieceClassName = piece.runtimeType.toString().toLowerCase();

    switch (pieceClassName) {
      case 'king':
        return PieceType.king;
      case 'queen':
        return PieceType.queen;
      case 'rook':
        return PieceType.rook;
      case 'bishop':
        return PieceType.bishop;
      case 'knight':
        return PieceType.knight;
      case 'pawn':
        return PieceType.pawn;
      default:
        throw UnsupportedError('Unsupported piece type: $pieceClassName');
    }
  }

  String renderText() {
    final pieceColor = color == PieceColor.white ? 'W' : 'B';
    final pieceType = runtimeType.toString().split('.').last;
    return '$pieceColor $pieceType';
  }

  String renderImage() {
    final pieceColor = color == PieceColor.white ? 'w' : 'b';
    var pieceType = runtimeType.toString().toLowerCase();
    String imagePiece;

    switch (pieceType) {
      case 'knight':
        imagePiece = pieceColor == 'w' ? 'N' : 'n';
        break;
      default:
        imagePiece = pieceColor == 'w' ? pieceType[0].toUpperCase() : pieceType[0];
        break;
    }
    return '$pieceColor$imagePiece.png';
  }

  bool hasMoved(Chessboard board) {
    return _hasMoved;
  }

  void setHasMoved(bool value) {
    _hasMoved = value;
  }

  set pos(Position? value) {
    pos = value;
  }
}

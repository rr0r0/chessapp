import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/position.dart';

enum PieceColor {
  white,
  black;

  PieceColor get opposite {
    return this == PieceColor.white ? PieceColor.black : PieceColor.white;
  }
}

abstract class Piece {
  final PieceColor color;
  Position? position;

  Piece({required this.color});

  bool canMoveTo(Chessboard board, Position to);

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
        imagePiece =
            pieceColor == 'w' ? pieceType[0].toUpperCase() : pieceType[0];
        break;
    }
    return '$pieceColor$imagePiece.png';
  }

  bool hasMoved(Chessboard board);
}

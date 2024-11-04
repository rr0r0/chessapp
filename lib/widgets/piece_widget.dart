import 'package:flutter/material.dart';
import 'package:chessapp/models/pieces/piece.dart';

class PieceWidget extends StatelessWidget {
  final Piece piece;

  const PieceWidget({super.key, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Text(piece.runtimeType.toString(), style: TextStyle(fontSize: 20));
  }
}
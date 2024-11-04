import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chessapp/models/pieces/king.dart';

class GameService with ChangeNotifier {
  Position? selectedPiece;
  final Chessboard board;
  Color currentTurn = Color.white;
  final List<Move> _moveHistory = [];
  final List<Piece> _movedPieces = [];
  final List<Chessboard> _boardHistory = [];

  Chessboard get currentBoard => board;

  GameService({required this.board});

  void handleTap(Position position) {
    if (selectedPiece != null) {
      if (selectedPiece == position) {
        // Unselect the piece if the same piece is tapped again
        selectedPiece = null;
      } else {
        final move = Move(from: selectedPiece!, to: position);
        if (board.isValidMove(move)) {
          makeMove(move);
          _moveHistory.add(move);
        }
        selectedPiece = null;
      }
    } else {
      final piece = currentBoard.board[position.row][position.col];
      if (piece != null) {
        selectedPiece = position;
      }
    }
    notifyListeners();
  }

  bool makeMove(Move move) {
    if (board.isValidMove(move)) {
      final piece = board.board[move.from.row][move.from.col];
      if (piece is King) {
        final colDiff = move.to.col - move.from.col;
        if (colDiff.abs() == 2) {
          // Castling move
          final rook = piece.getRook(board, move.to);
          if (rook != null && rook.position != null) {
            final rookMoveCol = move.to.col > move.from.col
                ? move.to.col - 1 // Kingside castling
                : move.to.col + 1; // Queenside castling
            board.movePiece(Move(
                from: rook.position!,
                to: Position(row: move.to.row, col: rookMoveCol)));
          }
        }
      }

      // Normal move handling
      _boardHistory.add(board.copy()); // Save board state for move history
      board.movePiece(
          move); // This will now add the move to Chessboard.moveHistory
      _moveHistory.add(
          move); // Also add to GameService's _moveHistory if needed for visual history
      _movedPieces.add(piece!);

      currentTurn = currentTurn == Color.white ? Color.black : Color.white;
      selectedPiece = null; // Unselect after move

      notifyListeners();
      return true;
    }
    return false;
  }

  List<String> get visualMoveHistory {
    if (board.moveHistory.isNotEmpty) {
      return board.moveHistory.asMap().entries.map((entry) {
        final moveIndex = entry.key;
        final move = entry.value;
        final piece = _movedPieces[moveIndex];
        final color = piece.color == PieceColor.white ? 'White' : 'Black';
        final pieceName = piece.runtimeType.toString().split('.').last;

        // Convert row to number and column to letter
        final fromRow = move.from.row;
        final fromCol = String.fromCharCode(97 + move.from.col);
        final toRow = move.to.row;
        final toCol = String.fromCharCode(97 + move.to.col);

        // Check if there is a piece at the destination (captured piece)
        final boardBeforeMove = _boardHistory[moveIndex];
        final capturedPiece = boardBeforeMove.board[move.to.row][move.to.col];
        if (capturedPiece != null) {
          final capturedColor =
              capturedPiece.color == PieceColor.white ? 'White' : 'Black';
          final capturedPieceName =
              capturedPiece.runtimeType.toString().split('.').last;
          return '$color $pieceName captures $capturedColor $capturedPieceName at $toCol$toRow from $fromCol$fromRow';
        } else if (piece is King && (move.to.col - move.from.col).abs() == 2) {
          final castlingSide = move.to.col > move.from.col ? 'King' : 'Queen';
          return '$color $pieceName castles at $castlingSide';
        } else {
          return '$color $pieceName moves from $fromCol$fromRow to $toCol$toRow';
        }
      }).toList();
    }
    return [];
  }
}

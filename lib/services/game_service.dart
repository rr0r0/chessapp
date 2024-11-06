import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:chessapp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:chessapp/models/pieces/king.dart';
import 'package:chessapp/models/pieces/pawn.dart';

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
        selectedPiece = null;
      } else {
        final move = Move(from: selectedPiece!, to: position);
        if (board.isValidMove(move)) {
          makeMove(move);
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
    if (piece != null) {
      // Save current board state before making the move
      _boardHistory.add(board.copy());

      // Make the move on the board
      board.movePiece(move);

      piece.position = move.to; // Update piece position
      piece.setHasMoved(true); // Mark piece as moved

      // Append move and piece to histories
      _moveHistory.add(move);
      _movedPieces.add(piece);

      // Switch turns
      currentTurn = currentTurn == Color.white ? Color.black : Color.white;
      selectedPiece = null;
      
      // Call method to print valid moves for the opponent's color
      printValidMovesForColor();

      notifyListeners();
      return true;
    }
  }
  return false;
}

  /// Method to print valid moves for a given color.
  void printValidMovesForColor() {
    final validMoves = board.getValidMovesForAllPieces();
    for (final move in validMoves) {
      print('Valid Moves: $move');
    }
  }

  /* final validMoves = getValidMovesForColor(color);
    print('Valid moves for $color pieces after move:');
    for (final move in validMoves) {
      print('Valid Moves: $move');
    } */

  /// Method to get valid moves for all pieces of a specified color.
  List<Move> getValidMovesForColor() {
    final allValidMoves = board.getValidMovesForAllPieces();
    final validMovesForColor = <Move>[];

    for (final tuple in allValidMoves) {
      /* if (tuple.item1 == color) {
        
      } */
     validMovesForColor.addAll(tuple.item2);
    }

    return validMovesForColor;
  }

  List<String> get visualMoveHistory {
    if (_moveHistory.isNotEmpty && _movedPieces.length == _moveHistory.length) {
      return _moveHistory.asMap().entries.map((entry) {
        final moveIndex = entry.key;
        final move = entry.value;
        final piece = _movedPieces[moveIndex];
        final color = piece.color == PieceColor.white ? 'White' : 'Black';
        final pieceName = piece.runtimeType.toString().split('.').last;

        final fromRow = move.from.row;
        final fromCol = String.fromCharCode(97 + move.from.col);
        final toRow = move.to.row;
        final toCol = String.fromCharCode(97 + move.to.col);

        final boardBeforeMove = _boardHistory[moveIndex];
        final capturedPiece = boardBeforeMove.board[move.to.row][move.to.col];

        if (move.capture == true) {
          if (capturedPiece != null) {
            final capturedColor =
                capturedPiece.color == PieceColor.white ? 'White' : 'Black';
            final capturedPieceName =
                capturedPiece.runtimeType.toString().split('.').last;

            return '$color $pieceName captures $capturedColor $capturedPieceName at $toCol${toRow + 1} from $fromCol${fromRow + 1}';
          } else {
            final capturedColor =
                piece.color == PieceColor.white ? 'Black' : 'White';
            if (piece is Pawn && (move.to.col - move.from.col).abs() == 1) {
              return '$color Pawn captures $capturedColor Pawn en passant at $toCol${toRow + 1} from $fromCol${fromRow + 1}';
            } else {
              return '$color $pieceName makes an unknown capture at $toCol${toRow + 1} from $fromCol${fromRow + 1}';
            }
          }
        } else if (piece is King && (move.to.col - move.from.col).abs() == 2) {
          final castlingSide = move.to.col > move.from.col ? 'King' : 'Queen';
          return '$color King castles at $castlingSide side';
        } else {
          return '$color $pieceName moves from $fromCol${fromRow + 1} to $toCol${toRow + 1}';
        }
      }).toList();
    } else {
      print(
          'Warning: _movedPieces is not synchronized with _moveHistory or histories are empty');
      print('_movedPieces: $_movedPieces, _moveHistory: $_moveHistory');
      return _moveHistory
          .map((move) =>
              'Move ${_moveHistory.indexOf(move) + 1} (no piece information)')
          .toList();
    }
  }
}

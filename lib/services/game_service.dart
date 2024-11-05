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

        if (piece is King && (move.to.col - move.from.col).abs() == 2) {
          final rook = piece.getRook(board, move.to);
          if (rook != null) {
            // Handle castling
            final row = move.to.row;
            final col = move.to.col > move.from.col ? 7 : 0;
            final rookCurrentPosition = Position(row: row, col: col);
            final rookMoveCol =
                move.to.col > move.from.col ? move.to.col - 1 : move.to.col + 1;
            board.movePiece(Move(
                from: rookCurrentPosition,
                to: Position(row: move.to.row, col: rookMoveCol)));
            rook.position = Position(row: move.to.row, col: rookMoveCol);
            rook.setHasMoved(true);

            // **Updated Castling Handling**
            // Add only the King to _movedPieces for castling moves
            // This maintains the 1:1 correspondence with _moveHistory
            _movedPieces.add(piece);
            piece.setHasMoved(true); // Ensure the king's _hasMoved flag is set
          }
        }

        // Make the move on the board
        board.movePiece(move);
        piece.position = move.to; // Update piece position
        piece.setHasMoved(true); // Mark piece as moved

        // Append move and piece to histories
        _moveHistory.add(move);
        if (!(piece is King && (move.to.col - move.from.col).abs() == 2)) {
          _movedPieces.add(piece); // Avoid adding king twice for castling
        }

        currentTurn = currentTurn == Color.white ? Color.black : Color.white;
        selectedPiece = null;
        notifyListeners();
        return true;
      }
    }
    return false;
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
        if (capturedPiece != null) {
          final capturedColor =
              capturedPiece.color == PieceColor.white ? 'White' : 'Black';
          final capturedPieceName =
              capturedPiece.runtimeType.toString().split('.').last;

          if (piece is Pawn &&
              (move.to.col - move.from.col).abs() == 1 &&
              board.board[move.to.row][move.to.col] == null) {
            final lastMove = _moveHistory.length > 1
                ? _moveHistory[_moveHistory.length - 2]
                : null;
            if (lastMove != null &&
                lastMove.to.row == move.from.row &&
                lastMove.to.col == move.to.col &&
                (lastMove.from.row - lastMove.to.row).abs() == 2) {
              // En passant confirmed
              return '$color Pawn captures $capturedColor Pawn en passant at $toCol${toRow + 1} from $fromCol${fromRow + 1}';
            } else {
              // Regular diagonal move, not en passant
              return '$color Pawn moves from $fromCol${fromRow + 1} to $toCol${toRow + 1}';
            }
          } else {
            return '$color $pieceName captures $capturedColor $capturedPieceName at $toCol${toRow + 1} from $fromCol${fromRow + 1}';
          }
        } else if (piece is King && (move.to.col - move.from.col).abs() == 2) {
          final castlingSide = move.to.col > move.from.col ? 'King' : 'Queen';
          return '$color King castles at $castlingSide side with Rook';
        } else {
          return '$color $pieceName moves from $fromCol${fromRow + 1} to $toCol${toRow + 1}';
        }
      }).toList();
    } else {
      // Handle desynchronization or empty histories
      print(
          'Warning: _movedPieces is not synchronized with _moveHistory or histories are empty');
      return _moveHistory
          .map((move) =>
              'Move ${_moveHistory.indexOf(move) + 1} (no piece information)')
          .toList();
    }
  }
}

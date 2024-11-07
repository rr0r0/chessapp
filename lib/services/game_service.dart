import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/models/move.dart';
import 'package:chessapp/models/pieces/piece.dart';
import 'package:chessapp/models/position.dart';
import 'package:flutter/material.dart';
import 'package:chessapp/models/pieces/king.dart';
import 'package:chessapp/models/pieces/pawn.dart';
import 'package:chessapp/utils/tuple.dart';

class GameService with ChangeNotifier {
  Position? selectedPiece;
  final Chessboard board;
  Piece? pieceObject;
  PieceColor currentTurn = PieceColor.white;
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
          if (_boardHistory.isNotEmpty) {
            final simulatedBoard = board.copy();
            if (!isInCheckAfterMove(move, simulatedBoard)) {
              makeMove(move);
            } else {
              _highlightError();
            }
          } else {
            makeMove(move);
          }
        }
        selectedPiece = null;
      }
    } else {
      final piece = currentBoard.board[position.row][position.col];
      if (piece != null) {
        if (piece.color == _getOpponentColor(currentTurn)) {
          _highlightError();
        } else {
          selectedPiece = position;
        }
      }
    }
    notifyListeners();
  }

  bool isInCheckAfterMove(Move move, Chessboard simulatedBoard) {
    // Simulate the move by directly modifying the piece positions
  Piece? piece = simulatedBoard.board[move.from.row][move.from.col];
  if (piece != null) {
    // Place piece on destination and remove it from origin
    simulatedBoard.board[move.from.row][move.from.col] = null;
    simulatedBoard.board[move.to.row][move.to.col] = piece;
    piece.position = move.to; // Update piece's position to the new one
  }

  // Get the opponent's moves on this simulated board
  final opponentMoves = simulatedBoard.getValidMovesForAllPieces(simulatedBoard);

  // Get the current player's king
  King king = Piece.getPiecesByTypeAndColor(currentTurn, PieceType.king, board: simulatedBoard).first as King;

  // Check if the king is in check
  print('opponentMoves: $opponentMoves, king: $king, board: $simulatedBoard');
  return isInCheck(opponentMoves, king, simulatedBoard);
  }

  bool makeMove(Move move) {
    final piece = board.board[move.from.row][move.from.col];
    if (piece != null) {
      // Save the current board state before making the move
      _boardHistory.add(board.copy());

      // Make the move on the board
      board.movePiece(move);

      piece.position = move.to; // Update piece position
      piece.setHasMoved(true); // Mark piece as moved

      // Append move and piece to histories
      _moveHistory.add(move);
      _movedPieces.add(piece);

      // Switch turns
      currentTurn = _getOpponentColor(currentTurn);
      selectedPiece = null;

      // Print valid moves for the opponent's color
      printValidMovesForColor(currentTurn);

      notifyListeners();
      return true;
    }
    return false;
  }

  PieceColor _getOpponentColor(PieceColor color) {
    return color == PieceColor.white ? PieceColor.black : PieceColor.white;
  }

  void printValidMovesForColor(PieceColor color) {
    final simulatedBoard = _boardHistory.last.copy();
    final validMoves = simulatedBoard.getValidMovesForColor(color, simulatedBoard);
    for (final move in validMoves) {
    }
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
          final castlingSide =
              move.to.col - move.from.col > 0 ? 'King' : 'Queen';
          return '$color King castles at $castlingSide side';
        } else {
          return '$color $pieceName moves from $fromCol${fromRow + 1} to $toCol${toRow + 1}';
        }
      }).toList();
    } else {
      return _moveHistory
          .map((move) =>
              'Move ${_moveHistory.indexOf(move) + 1} (no piece information)')
          .toList();
    }
  }

  Future<void> _highlightError() async {
    final oppositeTurnColor =
        currentTurn == PieceColor.white ? 'Black' : 'White';

    // Highlight the turn for a couple of seconds
    errorHighlight = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    errorHighlight = false;
    notifyListeners();
  }

  bool errorHighlight = false;

  bool isInCheck(List<Tuple<String, List<Move>>> opponentMoves, King piece,
      Chessboard board) {
    final position = piece.position;
    if (position != null) {
      return isSquareAttacked(opponentMoves, position, board);
    }
    return false;
  }

  bool isSquareAttacked(List<Tuple<String, List<Move>>> opponentMoves,
      Position square, Chessboard board) {
    for (final tuple in opponentMoves) {
      for (final move in tuple.item2) {
        if (move.to.row == square.row && move.to.col == square.col) {
          return true;
        }
      }
    }
    return false;
  }
}

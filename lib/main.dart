import 'package:flutter/material.dart';
import 'package:chessapp/models/chessboard.dart';
import 'package:chessapp/services/game_service.dart';
import 'package:chessapp/widgets/board_widget.dart';

void main() {
  runApp(ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChessBoardScreen(),
    );
  }
}

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  ChessBoardScreenState createState() => ChessBoardScreenState();
}

class ChessBoardScreenState extends State<ChessBoardScreen> {
  late final Chessboard board;
  late final GameService gameService;

  @override
  void initState() {
    super.initState();
    board = Chessboard.initial();
    gameService = GameService(board: board);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chess App'),
      ),
      body: BoardWidget(key: UniqueKey(), board: board, gameService: gameService),
    );
  }
}
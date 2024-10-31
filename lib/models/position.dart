class Position {
  final int row;
  final int col;

  Position({required this.row, required this.col});

  @override
  String toString() {
    return 'Position(row: $row, col: $col)';
  }
}
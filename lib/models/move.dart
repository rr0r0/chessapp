class Move {
  final String pieceName;
  final String from;
  final String to;
  final bool isCapture;
  final String description;

  Move(this.pieceName, this.from, this.to, {this.isCapture = false, required this.description});

  @override
  String toString() {
    return description;
  }
}

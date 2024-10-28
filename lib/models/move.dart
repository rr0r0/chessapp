class Move {
  final String pieceName;
  final String from;
  final String to;
  final bool isCapture;
  final String description; // Add this line to define description

  Move(this.pieceName, this.from, this.to, {this.isCapture = false, required this.description}); // Include description here

  @override
  String toString() {
    return description; // Use description directly in toString
  }
}

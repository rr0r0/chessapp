const int boardSize = 8;

enum Color {
  white,
  black
}

extension ColorExtension on Color {
  String get name {
    return this == Color.white ? 'White' : 'Black';
  }
}
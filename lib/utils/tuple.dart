class Tuple<T, U> {
  final T item1;
  final U item2;

  Tuple(this.item1, this.item2);

  @override
  String toString() {
    return 'Tuple($item1, $item2)';
  }
}
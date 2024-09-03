enum BookingType implements Comparable<BookingType> {
  ON_LOCATION(id: 1, simpleName: 'On-Location'),
  REMOTE(id: 10, simpleName: 'Remote');

  const BookingType({required this.id, required this.simpleName});
  final int id;
  final String simpleName;

  static BookingType bookingTypeByApiValue(String apiValue) {
    return BookingType.values.firstWhere(
        (BookingType) =>
            BookingType.name.toLowerCase() == apiValue.toLowerCase(),
        orElse: () => BookingType.ON_LOCATION);
  }

  @override
  int compareTo(BookingType other) => id - other.id;

  @override
  String toString() => simpleName;
}

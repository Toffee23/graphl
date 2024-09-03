enum BookingStatus implements Comparable<BookingStatus> {
  created(id: 1, simpleName: 'Created', apiValue: 'CREATED'),
  inProgress(id: 2, simpleName: 'In progress', apiValue: 'IN_PROGRESS'),
  bookieCompleted(id: 3, simpleName: 'Delivered', apiValue: 'BOOKIE_COMPLETED'),
  completed(id: 4, simpleName: 'Completed', apiValue: 'COMPLETED'),
  bookingReview(id: 6, simpleName: 'Booker review', apiValue: 'BOOKER_REVIEW'),
  clientReview(id: 7, simpleName: 'Client review', apiValue: 'CLIENT_REVIEW'),
  paymentCompleted(
      id: 8, simpleName: 'Payment completed', apiValue: 'PAYMENT_COMPLETED'),
  canceled(id: 9, simpleName: 'Canceled', apiValue: 'CANCELED');

  const BookingStatus(
      {required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static BookingStatus byApiValue(String apiValue) {
    final match = BookingStatus.values.firstWhere(
        (BookingStatus) =>
            BookingStatus.apiValue.toLowerCase() == apiValue.toLowerCase(),
        orElse: () => BookingStatus.created);
    return match;
  }

  @override
  int compareTo(BookingStatus other) => id - other.id;

  @override
  String toString() => simpleName;
}

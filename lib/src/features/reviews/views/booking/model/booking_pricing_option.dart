enum BookingPricingOption implements Comparable<BookingPricingOption> {
  PER_SERVICE(id: 1, simpleName: 'Per service'),
  PER_HOUR(id: 10, simpleName: 'Per hour');

  const BookingPricingOption({required this.id, required this.simpleName});
  final int id;
  final String simpleName;

  static BookingPricingOption bookingPricingOptionByApiValue(String apiValue) {
    return BookingPricingOption.values.firstWhere(
        (BookingPricingOption) =>
            BookingPricingOption.name.toLowerCase() == apiValue.toLowerCase(),
        orElse: () => BookingPricingOption.PER_SERVICE);
  }

  @override
  int compareTo(BookingPricingOption other) => id - other.id;

  @override
  String toString() => simpleName;
}

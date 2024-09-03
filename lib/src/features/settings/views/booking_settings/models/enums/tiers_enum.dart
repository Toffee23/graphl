enum ServiceTiers {
  basic(id: 1, simpleName: 'Standard', apiValue: 'STANDARD'),
  standard(id: 2, simpleName: "Pro", apiValue: 'PRO'),
  premium(id: 3, simpleName: 'Premium', apiValue: 'PREMIUM');

  const ServiceTiers({required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static ServiceTiers serviceTierByApiValue(String apiValue) {
    return ServiceTiers.values.firstWhere((tier) => tier.apiValue.toLowerCase() == apiValue.toLowerCase(), orElse: () => ServiceTiers.basic);
  }

  @override
  String toString() => simpleName;
}

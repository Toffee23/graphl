enum StatsPeriod implements Comparable<StatsPeriod> {
  eightDays(id: 1, simpleName: '8 days', apiValue: '8'),
  thirtyDays(id: 2, simpleName: '30 days', apiValue: '30'),
  sixMonths(id: 3, simpleName: '6 months', apiValue: '6months'),
  // week(id: 4, simpleName: 'weeks', apiValue: 'week'),
  year(id: 10, simpleName: 'year', apiValue: 'month');

  const StatsPeriod(
      {required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static StatsPeriod statDurationByApiValue(String apiValue) {
    return StatsPeriod.values.firstWhere(
        (gender) => gender.apiValue.toLowerCase() == apiValue.toLowerCase(),
        orElse: () => StatsPeriod.eightDays);
  }

  @override
  int compareTo(StatsPeriod other) => id - other.id;

  @override
  String toString() => simpleName;
}

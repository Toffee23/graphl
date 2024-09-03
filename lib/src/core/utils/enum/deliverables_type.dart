/// Deliverables type for digital services and jobs.
///

enum DeliverablesType implements Comparable<DeliverablesType> {
  content(id: 1, simpleName: 'Content', apiValue: 'CONTENT'),
  physical(id: 2, simpleName: 'Physical Service', apiValue: 'PHYSICAL'),
  other(id: 4, simpleName: 'Other', apiValue: 'OTHER');

  const DeliverablesType(
      {required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static DeliverablesType licenseTypeByApiValue(String apiValue) {
    return DeliverablesType.values.firstWhere(
            (licenseType) =>
        licenseType.apiValue.toLowerCase() == apiValue.toLowerCase(),
        orElse: () => DeliverablesType.content);
  }

  @override
  int compareTo(DeliverablesType other) => id - other.id;

  @override
  String toString() => simpleName;
}

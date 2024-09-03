enum WorkLocation implements Comparable<WorkLocation> {
  myLocation(id: 1, simpleName: 'My Location', apiValue: 'MY_LOCATION'),
  clientsLocation(id: 2, simpleName: "Client's Location", apiValue: 'CLIENTS_LOCATION'),
  remote(id: 3, simpleName: 'Remote', apiValue: 'REMOTE');

  const WorkLocation({required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static WorkLocation workLocationByApiValue(String apiValue) {
    return WorkLocation.values.firstWhere((WorkLocation) => WorkLocation.apiValue.toLowerCase() == apiValue.toLowerCase(), orElse: () => WorkLocation.myLocation);
  }

  @override
  int compareTo(WorkLocation other) => id - other.id;

  @override
  String toString() => simpleName;
}

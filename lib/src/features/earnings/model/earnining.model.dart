class EarningModel {
  double? earningsInMonth;
  InProgressValue? activeBookings;
  double? expensesToDate;
  int? completedJobCount;
  int? completedServiceCount;
  CompletionRate? completionRate;
  InProgressValue? jobsInProgress;
  InProgressValue? servicesInProgress;
  InProgressValue? totalEarnings;

  EarningModel({
    this.earningsInMonth,
    this.activeBookings,
    this.expensesToDate,
    this.completedJobCount,
    this.completedServiceCount,
    this.completionRate,
    this.jobsInProgress,
    this.servicesInProgress,
    this.totalEarnings,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      earningsInMonth: json['earningsInMonth'],
      activeBookings: json['activeBookings'] == null
          ? null
          : InProgressValue.fromJson(json['activeBookings']),
      expensesToDate: json['expensesToDate'],
      completedJobCount: json['completedJobsCount'],
      completedServiceCount: json['completedServicesCount'],
      completionRate: json['completionRate'] == null
          ? null
          : CompletionRate.fromJson(json['completionRate']),
      jobsInProgress: json['jobsInProgress'] == null
          ? null
          : InProgressValue.fromJson(json['jobsInProgress']),
      servicesInProgress: json['servicesInProgress'] == null
          ? null
          : InProgressValue.fromJson(json['servicesInProgress']),
      totalEarnings: json['totalEarnings'] == null
          ? null
          : InProgressValue.fromJson(json['totalEarnings']),
    );
  }
}

class CompletionRate {
  final double completionRate;
  final int totalBookings;
  final int completedBookings;

  CompletionRate(
      {required this.completionRate,
      required this.totalBookings,
      required this.completedBookings});

  factory CompletionRate.fromJson(Map<String, dynamic> json) => CompletionRate(
        completionRate: json['completionRate'],
        totalBookings: json['totalBookings'],
        completedBookings: json['completedBookings'],
      );
}

class InProgressValue {
  final int count;
  final double value;

  InProgressValue({required this.count, required this.value});

  factory InProgressValue.fromJson(Map<String, dynamic> json) =>
      InProgressValue(
        count: json['count'],
        value: json['value'],
      );
}

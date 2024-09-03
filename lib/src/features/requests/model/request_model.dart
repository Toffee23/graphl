import 'dart:convert';

import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_image_model.dart';

class RequestModel {
  final dynamic id;
  final VAppUser? requestedBy;
  final VAppUser? requestedTo;
  final RequestStatus status;
  final JobPostModel? job;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ServiceImageModel> banner;
  final WorkLocation? location;

  RequestModel({
    required this.id,
    required this.requestedBy,
    required this.requestedTo,
    required this.status,
    required this.job,
    required this.createdAt,
    required this.updatedAt,
    required this.banner,
    required this.location,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json['id'],
        requestedBy: VAppUser.fromMinimalMap(json['requestedBy']),
        requestedTo: VAppUser.fromMinimalMap(json['requestedTo']),
        status: RequestStatus.byApiValue(json['status']),
        job: json['job'] == null ? null : JobPostModel.fromMap(json['job']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        location: json['location'] == null ? null : WorkLocation.workLocationByApiValue(json['location']),
        banner: json['bannerUrl'] == null
            ? []
            : List<ServiceImageModel>.from(
                (json['bannerUrl'] as List).map<ServiceImageModel>(
                  (x) => ServiceImageModel.fromMap(jsonDecode(x)),
                ),
              ),
      );
}

enum RequestStatus implements Comparable<RequestStatus> {
  pending(id: 1, simpleName: 'Pending', apiValue: 'PENDING'),
  accpeted(id: 2, simpleName: 'Accepted', apiValue: 'ACCEPTED'),
  rejected(id: 3, simpleName: 'Rejected', apiValue: 'REJECTED');

  const RequestStatus({required this.id, required this.simpleName, required this.apiValue});
  final int id;
  final String simpleName;
  final String apiValue;

  static RequestStatus byApiValue(String apiValue) {
    final match = RequestStatus.values.firstWhere((requestStatus) => requestStatus.apiValue.toLowerCase() == apiValue.toLowerCase(), orElse: () => RequestStatus.pending);
    return match;
  }

  @override
  int compareTo(RequestStatus other) => id - other.id;

  @override
  String toString() => simpleName;
}

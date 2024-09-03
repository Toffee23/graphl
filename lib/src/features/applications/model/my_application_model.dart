import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';

class MyJobApplicationModel {
  String? id;
  JobPostModel? job;
  double? proposedPrice;
  bool? accepted;
  bool? rejected;
  bool? deleted;
  DateTime? dateCreated;

  MyJobApplicationModel({
    this.id,
    this.job,
    this.proposedPrice,
    this.accepted,
    this.rejected,
    this.deleted,
    this.dateCreated,
  });

  MyJobApplicationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    job = json['job'] != null ? new JobPostModel.fromMap(json['job']) : null;
    proposedPrice = json['proposedPrice'];
    accepted = json['accepted'];
    rejected = json['rejected'];
    deleted = json['deleted'];
    dateCreated = DateTime.parse(
        DateTime.parse(json['dateCreated']).toIso8601String().split("T")[0]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.job != null) {
      data['job'] = this.job!.toJson();
    }
    data['proposedPrice'] = this.proposedPrice;
    data['accepted'] = this.accepted;
    data['rejected'] = this.rejected;
    data['deleted'] = this.deleted;
    data['dateCreated'] = this.dateCreated;
    return data;
  }
}

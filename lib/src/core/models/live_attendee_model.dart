import 'package:vmodel/src/core/models/app_user.dart';

class LiveAttendeeModel {
  final id;
  final paid;
  final attendee;
  final paymentInfo;
  final liveClass;
  final dateCreated;
  final lastUpdated;

  LiveAttendeeModel(
    {
      this.id,
      this.paid,
      this.attendee,
      this.paymentInfo,
      this.liveClass,
      this.dateCreated,
      this.lastUpdated,
    }
  );

  factory LiveAttendeeModel.fromJson(Map<String, dynamic> data){
    return LiveAttendeeModel(
      id: data["id"],
      paid: data["paid"],
      attendee: data["attendee"] != null ? VAppUser.fromJson(data["attendee"]) : null,
      paymentInfo: data["paymentInfo"],
      liveClass: data["liveClass"],
      dateCreated: data["dateCreated"],
      lastUpdated: data["lastUpdated"],
    );
  }
}
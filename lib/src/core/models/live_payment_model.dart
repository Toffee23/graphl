import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/models/live_attendee_model.dart';
import 'package:vmodel/src/core/models/live_model.dart';

class LivePaymentModel {
  final id;
  final amount;
  final user;
  final paymentRef;
  final liveClass;
  final status;
  final paymentMethod;
  final createdAt;
  final updatedAt;
  final liveclassattendeeSet;

  LivePaymentModel(
      {
        this.id,
        this.amount,
        this.user,
        this.paymentRef,
        this.liveClass,
        this.status,
        this.paymentMethod,
        this.createdAt,
        this.updatedAt,
        this.liveclassattendeeSet,
      }
      );

  factory LivePaymentModel.fromJson(Map<String, dynamic> data){
    return LivePaymentModel(
      id: data["id"],
      amount: data["amount"],
      user: data["user"] != null ? VAppUser.fromJson(data["user"]) : null,
      paymentRef: data["paymentRef"],
      status: data["status"],
      paymentMethod: data["paymentMethod"],
      liveClass: data["liveClass"] != null ? LiveModel.fromJson(data["liveClass"]) : null,
      createdAt: data["createdAt"],
      updatedAt: data["updatedAt"],
      liveclassattendeeSet: data["liveclassattendeeSet"] != null ? data['liveclassattendeeSet']
          .map<LiveAttendeeModel>(
              (json) => LiveAttendeeModel.fromJson(json))
          .toList() : [],
    );
  }
}
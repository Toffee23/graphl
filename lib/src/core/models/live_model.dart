import 'dart:convert';

import 'package:vmodel/src/core/models/live_attendee_model.dart';
import 'package:vmodel/src/core/models/live_payment_model.dart';
import 'package:vmodel/src/core/models/live_timeline_model.dart';

class LiveModel {
  final id;
  final user;
  var title;
  var liveType;
  var description;
  var price;
  var startTime;
  var duration;
  var preparation;
  var prepIncluded;
  var classDifficulty;
  var status;
  var category;
  var banners;
  var hasTimeline;
  final dateCreated;
  final lastUpdated;
  final isDeleted;
  final liveclasstimelineSet;
  final liveclassattendeeSet;
  final liveclasspaymentSet;
  var timelines;
  final attendees;


  LiveModel(
      {this.id,
      this.user,
      this.title,
      this.liveType,
      this.description,
      this.price,
      this.startTime,
      this.duration,
      this.preparation,
      this.prepIncluded,
      this.classDifficulty,
      this.status,
      this.category,
      this.banners,
      this.hasTimeline,
      this.dateCreated,
      this.lastUpdated,
      this.isDeleted,
      this.liveclasstimelineSet,
      this.liveclassattendeeSet,
      this.liveclasspaymentSet,
      this.timelines,
      this.attendees});

  factory LiveModel.fromJson(Map<String, dynamic> data){
    return LiveModel(
      id: data["id"],
      user: data["user"],
      title: data["title"],
      liveType: data["liveType"],
      description: data["description"],
      price: data["price"],
      startTime: data["startTime"],
      duration: data["duration"],
      preparation: data["preparation"],
      prepIncluded: data["prepIncluded"],
      classDifficulty: data["classDifficulty"],
      status: data["status"],
      category: data["category"],
      banners: data["banners"],
      hasTimeline: data["hasTimeline"],
      dateCreated: data["dateCreated"],
      lastUpdated: data["lastUpdated"],
      isDeleted: data["isDeleted"],
      liveclasstimelineSet: data["liveclasstimelineSet"] != null ? data['liveclasstimelineSet']
          .map<LiveTimelineModel>(
              (json) => LiveTimelineModel.fromJson(json))
          .toList() : [],
      liveclassattendeeSet: data["liveclassattendeeSet"] != null ? data['liveclassattendeeSet']
          .map<LiveAttendeeModel>(
              (json) => LiveAttendeeModel.fromJson(json))
          .toList() : [],
      liveclasspaymentSet: data["liveclasspaymentSet"] != null ? data['liveclasspaymentSet']
          .map<LivePaymentModel>(
              (json) => LivePaymentModel.fromJson(json))
          .toList() : [],
      timelines: data["timelines"] != null ? data['predictions']
          .map<LiveTimelineModel>(
              (json) => LiveTimelineModel.fromJson(json))
          .toList() : [],
      attendees: data["attendees"] != null ? data['attendees']
          .map<LiveAttendeeModel>(
              (json) => LiveAttendeeModel.fromJson(json))
          .toList() : [],
    );
  }

  toJson(){
    List<String> timelineList = timelines.map((person) => jsonEncode(person.toJson())).toList();
    return {
      "liveClassData": {
        "title": title,
        "liveType": liveType,
        "description": description,
        "price": price,
        "startTime": startTime,
        "duration": duration,
        "preparation": preparation,
        "classDifficulty": classDifficulty,
        "category": category,
        "banners": banners,
        "timelines": timelineList,
      }
    };
  }
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/models/rating_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/payment_data_model.dart';

import '../../../../../core/models/id_name_field.dart';
import 'booking_data.dart';
import 'booking_pricing_option.dart';
import 'booking_status.dart';
import 'booking_type.dart';

@immutable
class BookingModel {
  final String? id;
  final BookingModule module;
  final int moduleId;
  final String title;
  final int price;
  final BookingPricingOption pricingOption;
  final BookingType bookingType;
  final bool haveBrief;
  final String deliverableType;
  final NameIDField? usageType;
  final NameIDField? usageLength;
  final String? brief;
  final String? briefLink;
  final String? briefFile;
  final DateTime startDate;
  final DateTime? completionDate;
  final DateTime? dateDelivered;
  final Map<String, dynamic> address;
  final VAppUser? moduleUser;
  final BookingStatus status;
  final bool expectDigitalContent;
  final DateTime dateCreated;
  final DateTime lastUpdated;
  final bool deleted;
  final VAppUser? user;
  final List<PaymentData> paymentSet;
  final List<Review> userReviewSet;

  BookingModel({
    this.id,
    required this.module,
    required this.moduleId,
    required this.title,
    required this.price,
    required this.pricingOption,
    required this.bookingType,
    required this.haveBrief,
    required this.deliverableType,
    this.usageType,
    this.usageLength,
    this.brief,
    this.briefLink,
    this.briefFile,
    required this.startDate,
    required this.completionDate,
    required this.dateDelivered,
    required this.address,
    this.moduleUser,
    required this.status,
    required this.expectDigitalContent,
    required this.dateCreated,
    required this.lastUpdated,
    required this.deleted,
    this.user,
    required this.paymentSet,
    required this.userReviewSet,
  });

  BookingModel copyWith({
    String? id,
    BookingModule? module,
    int? moduleId,
    String? title,
    int? price,
    BookingPricingOption? pricingOption,
    BookingType? bookingType,
    bool? haveBrief,
    String? deliverableType,
    NameIDField? usageType,
    NameIDField? usageLength,
    String? brief,
    String? briefLink,
    String? briefFile,
    DateTime? startDate,
    DateTime? completionDate,
    DateTime? dateDelivered,
    Map<String, dynamic>? address,
    VAppUser? moduleUser,
    BookingStatus? status,
    bool? expectDigitalContent,
    DateTime? dateCreated,
    DateTime? lastUpdated,
    bool? deleted,
    VAppUser? user,
    List<PaymentData>? paymentSet,
    List<Review>? userReviewSet,
  }) {
    return BookingModel(
        id: id ?? this.id,
        module: module ?? this.module,
        moduleId: moduleId ?? this.moduleId,
        title: title ?? this.title,
        price: price ?? this.price,
        pricingOption: pricingOption ?? this.pricingOption,
        bookingType: bookingType ?? this.bookingType,
        haveBrief: haveBrief ?? this.haveBrief,
        deliverableType: deliverableType ?? this.deliverableType,
        usageType: usageType ?? this.usageType,
        usageLength: usageLength ?? this.usageLength,
        brief: brief ?? this.brief,
        briefLink: briefLink ?? this.briefLink,
        briefFile: briefFile ?? this.briefFile,
        startDate: startDate ?? this.startDate,
        address: address ?? this.address,
        moduleUser: moduleUser ?? this.moduleUser,
        status: status ?? this.status,
        completionDate: completionDate ?? this.completionDate,
        dateDelivered: dateDelivered ?? this.dateDelivered,
        expectDigitalContent: expectDigitalContent ?? this.expectDigitalContent,
        dateCreated: dateCreated ?? this.dateCreated,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        deleted: deleted ?? this.deleted,
        user: user ?? this.user,
        paymentSet: paymentSet ?? this.paymentSet,
        userReviewSet: userReviewSet ?? this.userReviewSet);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'module': module.name,
      'moduleId': moduleId,
      'title': title,
      'price': price,
      'pricingOption': pricingOption.name,
      'bookingType': bookingType.name,
      'haveBrief': haveBrief,
      'deliverableType': deliverableType,
      'usageType': usageType?.toMap(),
      'usageLength': usageLength?.toMap(),
      'brief': brief,
      'briefLink': briefLink,
      'briefFile': briefFile,
      'startDate': startDate.toIso8601String(),
      'address': address,
      'moduleUser': moduleUser?.toMap(),
      'status': status.apiValue,
      'expectDigitalContent': expectDigitalContent,
      'dateCreated': dateCreated.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'deleted': deleted,
      'user': user?.toMap(),
      'paymentSet': paymentSet.map((x) => x.toMap()).toList(),
      'userreviewSet': userReviewSet.map((e) => e.toJson()).toList(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    try {
      //dev.log('[ooooollllliwiwiwiw] id: ${map["id"]}');
      //dev.log('[ooooollllliwiwiwiw] module: ${map["module"]}');
      return BookingModel(
        id: map['id'] != null ? map['id'] as String : null,
        module: BookingModule.values.byName(map['module'] as String),
        moduleId: map['moduleId'] as int,
        title: map['title'] as String,
        price: map['price'] as int,
        pricingOption: BookingPricingOption.values.byName(map['pricingOption'] as String),
        bookingType: BookingType.values.byName(map['bookingType'] as String),
        haveBrief: map['haveBrief'] as bool,
        deliverableType: map['deliverableType'] as String,
        usageType: map['usageType'] != null ? NameIDField.fromMap(map['usageType'] as Map<String, dynamic>) : null,
        usageLength: map['usageLength'] != null ? NameIDField.fromMap(map['usageLength'] as Map<String, dynamic>) : null,
        brief: map['brief'] != null ? map['brief'] as String : null,
        briefLink: map['briefLink'] != null ? map['briefLink'] as String : null,
        briefFile: map['briefFile'] != null ? map['briefFile'] as String : null,
        startDate: DateTime.parse(map['startDate'] as String),
        completionDate: map['completionDate'] != null ? DateTime.parse(map['completionDate']) : null,
        dateDelivered: map['dateDelivered'] != null ? DateTime.parse(map['dateDelivered']) : null,
        address: Map<String, dynamic>.from(jsonDecode(map['address'] as String)),
        moduleUser: map['moduleUser'] != null ? VAppUser.fromMinimalMap(map['moduleUser'] as Map<String, dynamic>) : null,
        status: BookingStatus.byApiValue(map['status'] as String),
        expectDigitalContent: map['expectDigitalContent'] as bool,
        dateCreated: DateTime.parse(map['dateCreated'] as String),
        lastUpdated: DateTime.parse(map['lastUpdated'] as String),
        deleted: map['deleted'] as bool,
        user: map['user'] != null ? VAppUser.fromMinimalMap(map['user'] as Map<String, dynamic>) : null,
        paymentSet: List<PaymentData>.from(
          (map['paymentSet'] as List).map<PaymentData>(
            (x) => PaymentData.fromMap(x as Map<String, dynamic>),
          ),
        ),
        userReviewSet: List<Review>.from((map['userreviewSet'] as List).map<Review>(
          (e) => Review.fromJson(e),
        )),
      );
    } catch (e) {
      //print('$e\n $st');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) => BookingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BookingModel(id: $id, module: $module, moduleId: $moduleId, title: $title, price: $price, pricingOption: $pricingOption, bookingType: $bookingType, haveBrief: $haveBrief, deliverableType: $deliverableType, usageType: $usageType, usageLength: $usageLength, brief: $brief, briefLink: $briefLink, briefFile: $briefFile, startDate: $startDate, address: $address, moduleUser: $moduleUser, status: $status, expectDigitalContent: $expectDigitalContent, dateCreated: $dateCreated, lastUpdated: $lastUpdated, deleted: $deleted, user: $user, paymentSet: $paymentSet)';
  }

  @override
  bool operator ==(covariant BookingModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.module == module &&
        other.moduleId == moduleId &&
        other.title == title &&
        other.price == price &&
        other.pricingOption == pricingOption &&
        other.bookingType == bookingType &&
        other.haveBrief == haveBrief &&
        other.deliverableType == deliverableType &&
        other.usageType == usageType &&
        other.usageLength == usageLength &&
        other.brief == brief &&
        other.briefLink == briefLink &&
        other.briefFile == briefFile &&
        other.startDate == startDate &&
        mapEquals(other.address, address) &&
        other.moduleUser == moduleUser &&
        other.status == status &&
        other.expectDigitalContent == expectDigitalContent &&
        other.dateCreated == dateCreated &&
        other.lastUpdated == lastUpdated &&
        other.deleted == deleted &&
        other.user == user &&
        listEquals(other.paymentSet, paymentSet);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        module.hashCode ^
        moduleId.hashCode ^
        title.hashCode ^
        price.hashCode ^
        pricingOption.hashCode ^
        bookingType.hashCode ^
        haveBrief.hashCode ^
        deliverableType.hashCode ^
        usageType.hashCode ^
        usageLength.hashCode ^
        brief.hashCode ^
        briefLink.hashCode ^
        briefFile.hashCode ^
        startDate.hashCode ^
        address.hashCode ^
        moduleUser.hashCode ^
        status.hashCode ^
        expectDigitalContent.hashCode ^
        dateCreated.hashCode ^
        lastUpdated.hashCode ^
        deleted.hashCode ^
        user.hashCode ^
        paymentSet.hashCode;
  }
}

// class BookingReview {
//   final String? ratingText;
//   final int? rating;
//   final dynamic id;
//   final VAppUser? reviewer;
//   final VAppUser? reviewed;

//   const BookingReview({
//     required this.ratingText,
//     required this.rating,
//     required this.id,
//     required this.reviewer,
//     required this.reviewed,
//   });

//   factory BookingReview.fromJson(Map<String, dynamic> json) => BookingReview(
//         ratingText: json['reviewText'],
//         rating: json['rating'],
//         id: json['id'],
//         reviewer: json['reviewer'] == null ? null : VAppUser.fromMinimalMap(json['reviewer']),
//         reviewed: json['reviewed'] == null ? null : VAppUser.fromMinimalMap(json['reviewed']),
//       );
// }

/*



  

  */
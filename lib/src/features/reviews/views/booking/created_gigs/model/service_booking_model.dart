import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/core/utils/enum/service_job_status.dart';
import 'package:vmodel/src/core/utils/enum/service_pricing_enum.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_image_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';

class ServiceBookingModel {
  final String id;
  final double price;
  final String title;
  final String description;
  final String delivery;
  final ServiceType? serviceType;
  final WorkLocation serviceLocation;
  final String? usageType;
  final String? deliverablesType;
  final String? usageLength;
  final bool isDigitalContentCreator;
  final bool hasAdditional;
  final bool? isOffer;
  final List<FAQModel>? faq;
  bool userLiked = false;
  final bool userSaved;
  final bool paused;
  final bool processing;
  final int percentDiscount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ServicePeriod servicePricing;
  final int? views;
  final int? shares;
  final int? saves;
  final int? likes;
  final List<ServiceImageModel> banner;
  final VAppUser? user;
  final int? initialDeposit;
  final List<String>? category;
  final ServiceOrJobStatus status;
  bool isLiked = false;
  final List<BookingModel> bookings;

  ServiceBookingModel({
    required this.id,
    required this.price,
    required this.title,
    required this.description,
    required this.delivery,
    this.serviceType,
    required this.serviceLocation,
    this.faq,
    this.usageType,
    this.usageLength,
    this.deliverablesType,
    required this.isDigitalContentCreator,
    required this.hasAdditional,
    this.isOffer,
    required this.userLiked,
    required this.userSaved,
    required this.paused,
    required this.processing,
    required this.percentDiscount,
    required this.createdAt,
    required this.updatedAt,
    required this.servicePricing,
    this.views,
    this.shares,
    this.saves,
    this.likes,
    required this.banner,
    this.user,
    this.initialDeposit,
    this.category,
    required this.status,
    this.isLiked = false,
    required this.bookings,
  });

  ServiceBookingModel copyWith({
    String? id,
    double? price,
    String? title,
    String? description,
    String? delivery,
    ServiceType? serviceType,
    WorkLocation? serviceLocation,
    String? usageType,
    String? usageLength,
    String? deliverablesType,
    bool? isDigitalContentCreator,
    bool? hasAdditional,
    bool? isOffer,
    List<FAQModel>? faq,
    bool? userLiked,
    bool? userSaved,
    bool? paused,
    bool? processing,
    int? percentDiscount,
    DateTime? createdAt,
    DateTime? updatedAt,
    ServicePeriod? servicePricing,
    int? views,
    int? shares,
    int? saves,
    int? likes,
    List<ServiceImageModel>? banner,
    VAppUser? user,
    int? initialDeposit,
    List<String>? category,
    ServiceOrJobStatus? status,
    List<BookingModel>? bookings,
  }) {
    return ServiceBookingModel(
      id: id ?? this.id,
      price: price ?? this.price,
      title: title ?? this.title,
      faq: faq ?? this.faq,
      description: description ?? this.description,
      delivery: delivery ?? this.delivery,
      serviceType: serviceType ?? this.serviceType,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      usageType: usageType ?? this.usageType,
      usageLength: usageLength ?? this.usageLength,
      deliverablesType: deliverablesType ?? this.deliverablesType,
      isDigitalContentCreator: isDigitalContentCreator ?? this.isDigitalContentCreator,
      hasAdditional: hasAdditional ?? this.hasAdditional,
      isOffer: isOffer ?? this.isOffer,
      userLiked: userLiked ?? this.userLiked,
      userSaved: userSaved ?? this.userSaved,
      paused: paused ?? this.paused,
      processing: processing ?? this.processing,
      percentDiscount: percentDiscount ?? this.percentDiscount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      servicePricing: servicePricing ?? this.servicePricing,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      likes: likes ?? this.likes,
      banner: banner ?? this.banner,
      user: user ?? this.user,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      category: category ?? this.category,
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'price': price,
      'title': title,
      'description': description,
      'deliveryTimeline': delivery,
      'serviceType': serviceType?.toJson(),
      'serviceLocation': serviceLocation.apiValue,
      'usageType': usageType,
      'usageLength': usageLength,
      'period': servicePricing.simpleName,
      'isDigitalContentCreator': isDigitalContentCreator,
      'hasAdditional': hasAdditional,
      'discount': percentDiscount,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': updatedAt.toIso8601String(),
      'views': views,
      'shares': shares,
      'faq': faq?.map((e) => e.toJson()).toList(),
      'likes': likes,
      'saves': saves,
      'userLiked': userLiked,
      'userSaved': userSaved,
      'user': user?.toMap(),
      'banner': banner.map((x) => x.toMap()).toList(),
      'initialDeposit': initialDeposit,
      'category': category,
      "isOffer": isOffer,
      'paused': paused,
      'processing': processing,
      'status': status.apiValue,
      'bookings': bookings.map((e) => e.toJson()).toList(),
    };
  }

  factory ServiceBookingModel.fromMap(Map<String, dynamic> map) {
    try {
      final deliveryMap = map['delivery'] ?? {};
      late String cate = "[]";
      if (map['category'].runtimeType == 'String') {
        cate = map['category'] ?? "[]";
      } else {
        final category = json.encode(map['category']).toString();
        if (category.contains('\\"')) {
          cate = map['category'];
        }
      }

      return ServiceBookingModel(
        id: map['id'].toString(),
        price: (map['price'] ?? 0.0),
        title: map['title'].toString(),
        faq: map['faq'] != null ? ((jsonDecode(map['faq'].toString()) as List).map((e) => FAQModel.fromJson(e)).toList()) : null,
        description: map['description'] as String,
        deliverablesType: map['deliverablesType'] ?? '',
        delivery: (deliveryMap['name'] ?? map['deliveryTimeline']).toString(),
        serviceLocation: map['serviceLocation'] == null ? WorkLocation.myLocation : WorkLocation.workLocationByApiValue(map['serviceLocation'] as String),
        serviceType: map['serviceType'] == null ? null : ServiceType.fromJson(map['serviceType']),
        usageType: map['usageType'] as String?,
        usageLength: map['usageLength'] as String?,
        servicePricing: ServicePeriod.servicePeriodByApiValue(map['period'] ?? 'Hour'),
        isDigitalContentCreator: map['isDigitalContentCreator'] ?? false,
        hasAdditional: map['hasAdditional'] ?? false,
        percentDiscount: map['discount'] as int,
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
        views: map['views'] ?? 0,
        shares: map['shares'] ?? 0,
        saves: map['saves'] ?? 0,
        likes: map['likes'] ?? 0,
        userLiked: map['userLiked'] ?? false,
        userSaved: map['userSaved'] ?? false,
        user: map['user'] != null ? VAppUser.fromMinimalMap(map['user'] as Map<String, dynamic>) : null,
        banner: map['banner'] == null
            ? []
            : List<ServiceImageModel>.from(
                (map['banner'] as List).map<ServiceImageModel>(
                  (x) => ServiceImageModel.fromMap(x as Map<String, dynamic>),
                ),
              ),
        initialDeposit: map['initialDeposit'],
        category: map['category'] != null ? List<String>.from(json.decode(cate)) : [],

        // (jsonDecode(map['category'])
        //     .map((item) => item.toString())
        //     .toList()) as List<String>,
        isOffer: (map['isOffer'] as bool?) ?? false,
        paused: (map['paused'] as bool?) ?? false,
        processing: (map['processing'] as bool?) ?? false,
        status: ServiceOrJobStatus.serviceOrJobStatusByApiValue((map['status'] as String?) ?? ''),
        bookings: List<BookingModel>.from((map['bookings'] as List).map((e) => BookingModel.fromMap(e))),
      );
    } catch (e) {
      //print('UUUUUUUUU $e \n $st');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory ServiceBookingModel.fromJson(String source) => ServiceBookingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServicePackageModel(id: $id, price: $price, title: $title, description: $description, delivery: $delivery, serviceType: $serviceType, usageType: $usageType, usageLength: $usageLength, isDigitalContentCreator: $isDigitalContentCreator, hasAdditional: $hasAdditional, isOffer: $isOffer, userLiked: $userLiked, userSaved: $userSaved, paused: $paused, processing: $processing, percentDiscount: $percentDiscount, createdAt: $createdAt, updatedAt: $updatedAt, servicePricing: $servicePricing, views: $views, shares: $shares, saves: $saves, likes: $likes, banner: $banner, user: $user, initialDeposit: $initialDeposit, status: $status, deliverablesType: $deliverablesType)';
  }

  @override
  bool operator ==(covariant ServiceBookingModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.price == price &&
        other.title == title &&
        other.description == description &&
        other.delivery == delivery &&
        other.serviceType == serviceType &&
        other.usageType == usageType &&
        other.usageLength == usageLength &&
        other.isDigitalContentCreator == isDigitalContentCreator &&
        other.hasAdditional == hasAdditional &&
        other.isOffer == isOffer &&
        other.userLiked == userLiked &&
        other.userSaved == userSaved &&
        other.paused == paused &&
        other.processing == processing &&
        other.percentDiscount == percentDiscount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.servicePricing == servicePricing &&
        other.views == views &&
        other.shares == shares &&
        other.saves == saves &&
        other.likes == likes &&
        listEquals(other.banner, banner) &&
        other.user == user &&
        other.initialDeposit == initialDeposit &&
        other.category == category &&
        other.status == status &&
        other.deliverablesType == deliverablesType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        price.hashCode ^
        title.hashCode ^
        description.hashCode ^
        delivery.hashCode ^
        serviceType.hashCode ^
        usageType.hashCode ^
        usageLength.hashCode ^
        isDigitalContentCreator.hashCode ^
        hasAdditional.hashCode ^
        isOffer.hashCode ^
        userLiked.hashCode ^
        userSaved.hashCode ^
        paused.hashCode ^
        processing.hashCode ^
        percentDiscount.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        servicePricing.hashCode ^
        views.hashCode ^
        shares.hashCode ^
        saves.hashCode ^
        likes.hashCode ^
        banner.hashCode ^
        user.hashCode ^
        initialDeposit.hashCode ^
        category.hashCode ^
        status.hashCode;
  }
}

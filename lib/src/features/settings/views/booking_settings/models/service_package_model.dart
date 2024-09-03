// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/enums/tiers_enum.dart';

import '../../../../../core/models/app_user.dart';
import '../../../../../core/utils/enum/service_job_status.dart';
import '../../../../../core/utils/enum/service_pricing_enum.dart';
import '../../../../../core/utils/enum/work_location.dart';
import 'service_image_model.dart';

@immutable
class ServicePackageModel {
  final String id;
  final double price;
  final String title;
  final String description;
  final String delivery;
  final ServiceType? serviceType;
  final ServiceType? serviceSubType;
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
  final TravelFee? travelFee;
  final ExpressDelivery? expressDelivery;
  final List<ServiceTierModel> serviceTier;

  ServicePackageModel({
    required this.id,
    required this.price,
    required this.title,
    required this.description,
    required this.delivery,
    this.serviceType,
    this.serviceSubType,
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
    this.travelFee,
    this.expressDelivery,
    required this.serviceTier,
  });

  ServicePackageModel copyWith(
      {String? id,
      double? price,
      String? title,
      String? description,
      String? delivery,
      ServiceType? serviceType,
      ServiceType? serviceSubType,
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
      TravelFee? travelFee,
      ExpressDelivery? expressDelivery,
      List<ServiceTierModel>? serviceTier}) {
    return ServicePackageModel(
      id: id ?? this.id,
      price: price ?? this.price,
      title: title ?? this.title,
      faq: faq ?? this.faq,
      description: description ?? this.description,
      delivery: delivery ?? this.delivery,
      serviceType: serviceType ?? this.serviceType,
      serviceSubType: serviceSubType ?? this.serviceSubType,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      usageType: usageType ?? this.usageType,
      usageLength: usageLength ?? this.usageLength,
      deliverablesType: deliverablesType ?? this.deliverablesType,
      isDigitalContentCreator:
          isDigitalContentCreator ?? this.isDigitalContentCreator,
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
      travelFee: travelFee ?? this.travelFee,
      expressDelivery: expressDelivery ?? this.expressDelivery,
      serviceTier: serviceTier ?? this.serviceTier,
    );
  }

  Map<String, dynamic> duplicateMap() {
    return <String, dynamic>{
      'price': price,
      'title': "$title Copy",
      'description': description,
      'deliveryTimeline': delivery,
      'serviceType': serviceType?.toJson(),
      'subType': serviceSubType?.toJson(),
      'serviceLocation': serviceLocation.apiValue,
      'usageType': usageType,
      'usageLength': usageLength,
      'period': servicePricing.simpleName,
      'isDigitalContentCreator': isDigitalContentCreator,
      'hasAdditional': hasAdditional,
      'discount': percentDiscount,
      'bannerUrl': banner.map((x) => x.toMap()).toList(),
      'initialDeposit': initialDeposit,
      'category': category,
      "isOffer": isOffer,
      "faq": faq,
      "paused": paused,
      "publish": false,
      "serviceTier": serviceTier.map((x) => x.toJson(x)).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'price': price,
      'title': title,
      'description': description,
      'deliveryTimeline': delivery,
      'serviceType': serviceType?.toJson(),
      'subType': serviceSubType?.toJson(),
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
    };
  }

  factory ServicePackageModel.fromMap(Map<String, dynamic> map) {
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
      return ServicePackageModel(
          id: map['id'].toString(),
          price: (map['price'] ?? 0.0),
          title: map['title'].toString(),
          faq: map['faq'] != null
              ? ((jsonDecode(map['faq'].toString()) as List)
                  .map((e) => FAQModel.fromJson(e))
                  .toList())
              : null,
          description: map['description'] as String,
          deliverablesType: map['deliverablesType'] ?? '',
          delivery: (deliveryMap['name'] ?? map['deliveryTimeline']).toString(),
          serviceLocation: map['serviceLocation'] == null
              ? WorkLocation.myLocation
              : WorkLocation.workLocationByApiValue(
                  map['serviceLocation'] as String),
          serviceType: map['serviceType'] == null || map['serviceType'] is String
              ? null
              : ServiceType.fromJson(map['serviceType']),
          serviceSubType: map['subType'] == null || map['subType'] is String
              ? null
              : ServiceType.fromJson(map['subType']),
          travelFee: map['travelFee'] == null || jsonDecode(map['travelFee'] as String? ?? '{}').isEmpty
              ? null
              : TravelFee.fromJson(jsonDecode(map['travelFee'])),
          expressDelivery: map['expressDelivery'] == null ||
                  jsonDecode(map['expressDelivery'] as String? ?? '{}').isEmpty
              ? null
              : ExpressDelivery.fromJson(jsonDecode(map['expressDelivery'])),
          usageType: map['usageType'] as String?,
          usageLength: map['usageLength'] as String?,
          servicePricing:
              ServicePeriod.servicePeriodByApiValue(map['period'] ?? 'Hour'),
          isDigitalContentCreator: map['isDigitalContentCreator'] ?? false,
          hasAdditional: map['hasAdditional'] ?? false,
          percentDiscount: map['discount'] as int,
          createdAt:
              DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
          updatedAt:
              DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
          views: map['views'] ?? 0,
          shares: map['shares'] ?? 0,
          saves: map['saves'] ?? 0,
          likes: map['likes'] ?? 0,
          userLiked: map['userLiked'] ?? false,
          userSaved: map['userSaved'] ?? false,
          user: map['user'] != null
              ? VAppUser.fromMinimalMap(map['user'] as Map<String, dynamic>)
              : null,
          banner: map['banner'] == null
              ? []
              : List<ServiceImageModel>.from(
                  (map['banner'] as List).map<ServiceImageModel>(
                    (x) => ServiceImageModel.fromMap(x as Map<String, dynamic>),
                  ),
                ),
          initialDeposit: map['initialDeposit'],
          category: map['category'] != null
              ? List<String>.from(json.decode(cate))
              : [],

          // (jsonDecode(map['category'])
          //     .map((item) => item.toString())
          //     .toList()) as List<String>,
          isOffer: (map['isOffer'] as bool?) ?? false,
          paused: (map['paused'] as bool?) ?? false,
          processing: (map['processing'] as bool?) ?? false,
          status: ServiceOrJobStatus.serviceOrJobStatusByApiValue(
              (map['status'] as String?) ?? ''),
          serviceTier: map['tiers'] == null
              ? []
              : List<ServiceTierModel>.from((map['tiers'] as List).map((x) => ServiceTierModel.fomJson(x))));
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      rethrow;
    }
  }

  factory ServicePackageModel.fromMiniMap(Map<String, dynamic> map,
      {bool discardUser = true}) {
    // if (discardUser) map['user'] = null;
    try {
      map['user'] = map['user'] ?? null;
      map['delivery'] =
          map['delivery'] ?? {"name": VConstants.kDeliveryOptions.first};
      map['serviceLocation'] =
          map['serviceLocation'] ?? WorkLocation.myLocation.apiValue;
      map['usageType'] = map['usageType'] ?? "Private";
      map['usageLength'] = map['usageLength'] ?? "1 week";
      map['discount'] = -1;
      map['expressDelivery'] = map['expressDelivery'];
      map['serviceType'] =
          map['serviceType'] == null || map['serviceType'] is String
              ? null
              : map['serviceType'];
      map['subType'] = map['subType'] == null || map['subType'] is String
          ? null
          : map['subType'];
      return ServicePackageModel.fromMap(map);
    } catch (e, s) {
      logger.e(e, stackTrace: s);
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory ServicePackageModel.fromJson(String source) =>
      ServicePackageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ServicePackageModel(id: $id, price: $price, title: $title, description: $description, delivery: $delivery, serviceType: $serviceType, usageType: $usageType, usageLength: $usageLength, isDigitalContentCreator: $isDigitalContentCreator, hasAdditional: $hasAdditional, isOffer: $isOffer, userLiked: $userLiked, userSaved: $userSaved, paused: $paused, processing: $processing, percentDiscount: $percentDiscount, createdAt: $createdAt, updatedAt: $updatedAt, servicePricing: $servicePricing, views: $views, shares: $shares, saves: $saves, likes: $likes, banner: $banner, user: $user, initialDeposit: $initialDeposit, status: $status, deliverablesType: $deliverablesType)';
  }

  @override
  bool operator ==(covariant ServicePackageModel other) {
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

class TravelFee {
  final double price;
  final String policy;

  TravelFee({required this.price, required this.policy});

  factory TravelFee.fromJson(Map<String, dynamic> json) => TravelFee(
        price: json['price'],
        policy: json['travel_policy'] ?? '',
      );
}

class ServiceType {
  final dynamic id;
  final String name;
  final List<ServiceType> subType;

  ServiceType({required this.id, required this.name, required this.subType});

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
        id: json['id'],
        name: json['name'],
        subType: json['subTypes'] == null
            ? []
            : List<ServiceType>.from(
                (json['subTypes'] as List).map<ServiceType>(
                  (x) => ServiceType.fromJson(x as Map<String, dynamic>),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subType': subType.map((e) => e.toJson()).toList(),
      };
}

class FAQModel {
  String? question;
  String? answer;
  FAQModel({this.question, this.answer});

  FAQModel.fromJson(Map<dynamic, dynamic> json) {
    question = json['question'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}

class ExpressDelivery {
  final double price;
  final String delivery;

  ExpressDelivery({required this.price, required this.delivery});

  factory ExpressDelivery.fromJson(Map<String, dynamic> json) =>
      ExpressDelivery(
        price: json['price'],
        delivery: json['delivery'],
      );
}

/// [ServiceTierModel] model class for the service tiers
class ServiceTierModel {
  /// holds the enum value for the [ServiceTierModel]
  final ServiceTiers tier;

  /// [title] of the currrent [ServiceTierModel]
  final String title;

  /// [desc] of the currrent [ServiceTierModel]
  final String desc;

  ///[price] of the currrent [ServiceTierModel]
  final double price;

  /// [revision] a service tier offers
  final int revision;

  ///[addons] of the currrent [ServiceTierModel] by default its going to be a single itemed list
  final List<ServiceTierAddOn> addons;

  ServiceTierModel({
    required this.tier,
    required this.title,
    required this.desc,
    required this.price,
    required this.addons,
    required this.revision,
  });

  factory ServiceTierModel.fomJson(Map<String, dynamic> json) =>
      ServiceTierModel(
        tier: ServiceTiers.serviceTierByApiValue(json['tier']),
        title: json['customTitle'],
        desc: json['customDescription'],
        price: json['price'],
        revision: json['revisions'],
        addons: List<ServiceTierAddOn>.from(
          (json['addons'] as List).map<ServiceTierAddOn>(
            (x) => ServiceTierAddOn.fromJson(x as Map<String, dynamic>),
          ),
        ),
      );

  Map<String, dynamic> toJson(ServiceTierModel tier) => {
        'tier': tier.tier.apiValue,
        'customTitle': tier.title,
        'customDescription': tier.desc,
        'price': price,
        'revisions': revision,
        'addons': tier.addons.map((e) => e.toJson(e)).toList(),
      };
}

/// [ServiceTierOption] this can also be revision for a service tier
/// [name] of the [ServiceTierOption] and also the [value] for the [ServiceTierOption]

class ServiceTierOption {
  /// [name] by default would be called revision but future update might say otherwise
  final String name;

  ///[value] is defaulted to be the version of the revision
  final String value;

  ServiceTierOption({required this.name, required this.value});

  /// [ServiceTierOption.fromJson] parses the json value to the [ServiceTierOption]
  factory ServiceTierOption.fromJson(Map<String, dynamic> json) =>
      ServiceTierOption(
        name: json['name'],
        value: json['value'],
      );
}

/// [ServiceTierAddOn] hold the model class for the ServiceTier addon features
class ServiceTierAddOn {
  ///[name] of the  service tier addon
  final String name;

  ///[price] of the service tier addon but wont be used in this update
  final double price;

  ///[desc] of the service tier addon null by default
  final String desc;

  ServiceTierAddOn(
      {required this.name, required this.price, required this.desc});

  factory ServiceTierAddOn.fromJson(Map<String, dynamic> json) =>
      ServiceTierAddOn(
          name: json['addOnName'],
          price: json['price'],
          desc: json['description']);

  Map<String, dynamic> toJson(ServiceTierAddOn tierAddOn) => {
        'addOnName': tierAddOn.name,
        'price': tierAddOn.price,
        'description': tierAddOn.desc,
      };
}

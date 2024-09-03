

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:vmodel/src/core/models/bust_model.dart';
import 'package:vmodel/src/core/models/chest.dart';
import 'package:vmodel/src/core/models/feet_model.dart';
import 'package:vmodel/src/core/models/height_model.dart';
import 'package:vmodel/src/core/models/location_model.dart';
import 'package:vmodel/src/core/models/phone_number_model.dart';
import 'package:vmodel/src/core/models/user_socials.dart';
import 'package:vmodel/src/core/models/vmc_record_model.dart';
import 'package:vmodel/src/core/models/waist_model.dart';
import 'package:vmodel/src/core/utils/enum/ethnicity_enum.dart';
import 'package:vmodel/src/core/utils/enum/gender_enum.dart';
import 'package:vmodel/src/core/utils/enum/size_enum.dart';

@immutable
class SavedCouponModel {
  final int? id;
  final bool? deleted;
  final VAppUserDemo? user;
  final DateTime? createdAt;
  final int?  boardId;
  final CouponModel? coupon;
  final bool? userSaved;

//Generated
  const SavedCouponModel({
    required this.deleted,
    required this.user,
    required this.id,
    required this.createdAt,
    required this.boardId,
    required this.coupon,
    required this.userSaved,
  });

  SavedCouponModel copyWith(
      {required String code, required String title, required int id}) {
    return SavedCouponModel(
        id: id,
      deleted: deleted,
      user: user,
      createdAt: createdAt,
      boardId: boardId,
      coupon: coupon,
        userSaved: userSaved
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'deleted': deleted,
      'user': user,
      'createdAt': createdAt?.toIso8601String()??null,
      'boardId': boardId,
      'userSaved': userSaved,
      'coupon': coupon
    };
  }

  factory SavedCouponModel.fromMap(Map<String, dynamic> map) {
    try {
      dynamic id = map['id']!=null?  int.parse(map['id']):null;
      dynamic deleted = map['deleted'];
      dynamic user = map['user']==null?null: VAppUserDemo.fromMap(map['user']??{});
      dynamic createdAt = DateTime.parse(map['createdAt']??DateTime.now().toString());
      dynamic boardId = map['boardId']!=null? map['boardId']:null;
      dynamic coupon = map['coupon']==null?null:CouponModel.fromMap(map['coupon']??{}) ;
      dynamic userSaved = map['userSaved'] ;

      return SavedCouponModel(
          id: id,
          deleted: deleted,
          user: user,
          createdAt: createdAt,
          boardId: boardId,
          coupon: coupon,
          userSaved: userSaved
      );
    } catch (e) {
      //print('$e \n $st');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());


}


@immutable
class CouponModel {
  // final DateTime date;
  // final Duration startTime;
  // final Duration endTime;
  // final bool isFullDay;

  final String? code;
  final String? title;
  final String? id;

  final List? pinnedCoupons;
  final bool? deleted;
  final VAppUserDemo? owner;
  final DateTime? expiryDate;
  final int? useLimit;
  final DateTime? dateCreated;
  final int?  copyCountl;
  final int? saves;
  final SavedCouponModel? savedcouponSet;
  final SavedCouponModel? savedcouponboardSet;
  final bool? isExpired;

//Generated
  const CouponModel({
    required this.code,
    required this.title,
    required this.id,
    required this.deleted,
    required this.pinnedCoupons,
    required this.dateCreated,
    required this.copyCountl,
    required this.expiryDate,
    required this.isExpired,
    required this.savedcouponboardSet,
    required this.owner,
    required this.savedcouponSet,
    required this.saves,
    required this.useLimit,
  });

  CouponModel copyWith(
      {required String code, required String title, required String id}) {
    return CouponModel(
        code: code, 
        title: title,
        id: id,
      deleted: deleted,
      pinnedCoupons: pinnedCoupons,
      dateCreated: dateCreated,
      copyCountl: copyCountl,
      expiryDate: expiryDate,
      isExpired: isExpired,
      savedcouponboardSet: savedcouponboardSet,
      owner: owner,
      savedcouponSet: savedcouponSet,
      saves: saves,
      useLimit: useLimit
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'date': '${date.year}-${date.month}-${date.day}',
      'code': code,
      'title': title,
      'id': id,
      'deleted': deleted,
      'pinnedCoupons': pinnedCoupons,
      'dateCreated': dateCreated,
      'copyCountl': copyCountl,
      'expiryDate': expiryDate,
      'isExpired': isExpired,
      'savedcouponboardSet': savedcouponboardSet,
      'owner': owner,
      'savedcouponSet': savedcouponSet,
      'saves': saves,
      'useLimit': useLimit
    };
  }

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    try {
      dynamic code = map['code'] ;
      // start = int.parse(start);
      dynamic title = map['title'] ;
      dynamic id = map['id'] ;
      dynamic deleted = map['deleted'] ;
      dynamic pinnedCoupons = map['pinnedCoupons'] ;
      dynamic dateCreated = map['dateCreated'] ;
      dynamic copyCountl = map['copyCountl'] ;
      dynamic expiryDate = DateTime.parse(map['expiryDate'] ?? DateTime.now().toString());
      dynamic isExpired = map['isExpired'] ;
      dynamic owner =VAppUserDemo.fromMap(map['owner']??{}) ;
      dynamic savedcouponboardSet = SavedCouponModel.fromMap(map['savedcouponboardSet']??{});
      dynamic savedcouponSet = SavedCouponModel.fromMap(map['savedcouponSet']??{} );
      dynamic saves = map['saves'] ;
      dynamic useLimit = map['useLimit'] ;
      

      return CouponModel(
        code: code,
        title: title,
        id: id,
          deleted: deleted,
          pinnedCoupons: pinnedCoupons,
          dateCreated: dateCreated,
          copyCountl: copyCountl,
          expiryDate: expiryDate,
          isExpired: isExpired,
          savedcouponboardSet: savedcouponboardSet,
          owner: owner,
          savedcouponSet: savedcouponSet,
          saves: saves,
          useLimit: useLimit
      );
    } catch (e) {
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());


  @override
  String toString() {
    return 'CouponModel(code: $code, title: $title,)';
  }

  @override
  bool operator ==(covariant CouponModel other) {
    if (identical(this, other)) return true;

    return other.code == code && other.title == title;
  }

  @override
  int get hashCode {
    return code.hashCode ^ title.hashCode;
  }
}

@immutable
class CouponBoardModel {
  // final DateTime date;
  // final Duration startTime;
  // final Duration endTime;
  // final bool isFullDay;

  final String? code;
  final String? title;
  final String? id;
  final CouponModel? coupons;
  final List? pinnedCoupons;
  final VAppUserDemo? user;
  final bool? pinned;
  final DateTime? createdAt;
  final bool? deleted;
  final int? numberOfCoupons;

//Generated
  const CouponBoardModel({
    required this.code,
    required this.title,
    required this.id,
    required this.user,
  required this.coupons,
  required this.createdAt,
  required this.deleted,
  required this.numberOfCoupons,
  required this.pinned,
  required this.pinnedCoupons
  });

  CouponBoardModel copyWith(
      {required String code, required String title, required String id,
        required CouponModel coupons,
        required List pinnedCoupons,
        required VAppUserDemo user,
        required bool pinned,
        required DateTime createdAt,
        required bool deleted,
        required int numberOfCoupons,
      }) {
    return CouponBoardModel(
        code: code, 
        title: title, 
        id: id,
      user:user,
      coupons: coupons,
      createdAt: createdAt,
      deleted: deleted,
      numberOfCoupons: numberOfCoupons,
      pinned: pinned,
      pinnedCoupons: pinnedCoupons
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'date': '${date.year}-${date.month}-${date.day}',
      'code': code,
      'title': title,
      'id': id,
      'user':user,
      'coupons': coupons,
      'createdAt': createdAt?.toIso8601String()??null,
      'deleted': deleted,
      'numberOfCoupons': numberOfCoupons,
      'pinned': pinned,
      'pinnedCoupons': pinnedCoupons
    };
  }

  factory CouponBoardModel.fromMap(Map<String, dynamic> map) {
    try {
      dynamic code = map['code'] ;
      // start = int.parse(start);
      dynamic title = map['title'] ;
      dynamic id = map['id'] ;
      dynamic pinnedCoupons = map['pinnedCoupons'] ;
      dynamic user =  null ;
      dynamic coupons = null;
      dynamic createdAt = DateTime.parse(map['createdAt']??DateTime.now().toString()) ;
      dynamic deleted = map['deleted'] ;
      dynamic numberOfCoupons = map['numberOfCoupons'] ;
      dynamic pinned = map['pinned'] ;
      //end = int.parse(end);

      return CouponBoardModel(
        code: code,
        title: title,
        id: id,
        user:user,
        coupons: coupons,
        createdAt: createdAt,
        deleted: deleted,
        numberOfCoupons: numberOfCoupons,
        pinned: pinned,
        pinnedCoupons: pinnedCoupons
      );
    } catch (e) {
      //print('$e \n $st');
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());


  @override
  int get hashCode {
    return code.hashCode ^ title.hashCode;
  }
}

class VAppUserDemo {
  // final AuthStatus status;
  final bool? allowConnectionView;
  final int? id;
  final String? firstName;
  final String? email;
  final String? lastName;
  final String? username;
  final String? displayName;
  final String? whoCanConnectWithMe;
  final String? whoCanFeatureMe;
  final String? whoCanMessageMe;
  final String? whoCanViewMyNetwork;
  final bool? alertOnProfileVisit;
  final DateTime? dob;
  final PhoneNumberModel? phone;
  final String? connectionStatus;
  final int? connectionId;
  final Gender? gender;
  final Ethnicity? ethnicity;
  final String? bio;
  final VMCRecordModel? vmcrecord;
  final String? website;
  final String? weight;
  final String? hair;
  final String? eyes;
  final double? price;
  final LocationData? location;
  final String? profilePictureUrl;
  final String? thumbnailUrl;
  final bool? isVerified;
  final bool? blueTickVerified;
  final ModelSize? modelSize;
  final bool? isBusinessAccount;
  final String? userType;
  final String? label;
  final String? zodiacSign;
  final String? displayZodiacSign;
  final String? personality;
  final UserSocials? socials;
  final bool? isFollowing;
  final bool? postNotification;
  final bool? jobNotification;
  final bool? couponNotification;
  final int? yearsOfExperience;
  final double? rating;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  final HeightModel? height;
  final WaistModel? waist;
  final ChestModel? chest;
  final FeetModel? feet;
  final BustModel? bust;
  bool isLiked = false;


  String get fullName => '$firstName $lastName';


  VAppUserDemo({
    this.allowConnectionView,
    this.id,
    required this.firstName,
    required this.email,
    required this.lastName,
    required this.username,
    required this.displayName,
    this.dob,
    this.phone,
    this.connectionStatus,
    this.connectionId,
    this.gender,
    this.ethnicity,
    this.bio,
    required this.whoCanConnectWithMe,
    required this.whoCanFeatureMe,
    required this.whoCanMessageMe,
    required this.whoCanViewMyNetwork,
    required this.alertOnProfileVisit,
    this.vmcrecord,
    this.website,
    this.weight,
    this.hair,
    this.eyes,
    this.price,
    this.rating,
    this.location,
    this.profilePictureUrl,
    this.thumbnailUrl,
    required this.isVerified,
    required this.blueTickVerified,
    this.modelSize,
    this.isBusinessAccount,
    this.userType,
    this.label,
    this.zodiacSign,
    this.personality,
    this.socials,
    this.isFollowing,
    this.postNotification,
    this.jobNotification,
    this.couponNotification,
    this.yearsOfExperience,
    this.height,
    this.waist,
    this.chest,
    this.feet,
    this.bust,
    this.dateJoined,
    this.lastLogin,
    this.isLiked = false,
    this.displayZodiacSign,
  });

  VAppUserDemo copyWith({
    bool? allowConnectionView,
    int? id,
    String? firstName,
    String? email,
    String? lastName,
    String? username,
    String? displayName,
    DateTime? dob,
    PhoneNumberModel? phone,
    String? connectionStatus,
    int? connectionId,
    Gender? gender,
    Ethnicity? ethnicity,
    String? bio,
    VMCRecordModel? vmcrecord,
    String? website,
    String? weight,
    String? hair,
    String? eyes,
    double? price,
    LocationData? location,
    String? profilePictureUrl,
    String? thumbnailUrl,
    bool? isVerified,
    bool? blueTickVerified,
    ModelSize? modelSize,
    bool? isBusinessAccount,
    String? userType,
    String? label,
    double? rating,
    String? zodiacSign,
    String? personality,
    UserSocials? socials,
    bool? isFollowing,
    bool? postNotification,
    bool? jobNotification,
    bool? couponNotification,
    int? yearsOfExperience,
    HeightModel? height,
    WaistModel? waist,
    ChestModel? chest,
    FeetModel? feet,
    BustModel? bust,
    String? whoCanConnectWithMe,
    String? whoCanFeatureMe,
    String? whoCanMessageMe,
    String? whoCanViewMyNetwork,
    bool? alertOnProfileVisit,
    String? displayZodiacSign,
  }) {
    return VAppUserDemo(
        allowConnectionView: allowConnectionView ?? this.allowConnectionView,
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        email: email ?? this.email,
        lastName: lastName ?? this.lastName,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        dob: dob ?? this.dob,
        phone: phone ?? this.phone,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        connectionId: connectionId ?? this.connectionId,
        gender: gender ?? this.gender,
        ethnicity: ethnicity ?? this.ethnicity,
        bio: bio ?? this.bio,
        vmcrecord: vmcrecord ?? this.vmcrecord,
        website: website ?? this.website,
        weight: weight ?? this.weight,
        hair: hair ?? this.hair,
        eyes: eyes ?? this.eyes,
        price: price ?? this.price,
        location: location ?? this.location,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        isVerified: isVerified ?? this.isVerified,
        blueTickVerified: blueTickVerified ?? this.blueTickVerified,
        modelSize: modelSize ?? this.modelSize,
        isBusinessAccount: isBusinessAccount ?? this.isBusinessAccount,
        userType: userType ?? this.userType,
        label: label ?? this.label,
        rating: rating ?? this.rating,
        zodiacSign: zodiacSign ?? this.zodiacSign,
        personality: personality ?? this.personality,
        socials: socials ?? this.socials,
        isFollowing: isFollowing ?? this.isFollowing,
        postNotification: postNotification ?? this.postNotification,
        jobNotification: jobNotification ?? this.jobNotification,
        couponNotification: couponNotification ?? this.couponNotification,
        yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
        height: height ?? this.height,
        waist: waist ?? this.waist,
        chest: chest ?? this.chest,
        feet: feet ?? this.feet,
        bust: bust ?? this.bust,
        whoCanConnectWithMe: whoCanConnectWithMe ?? this.whoCanConnectWithMe,
        whoCanFeatureMe: whoCanFeatureMe ?? this.whoCanFeatureMe,
        whoCanMessageMe: whoCanMessageMe ?? this.whoCanMessageMe,
        whoCanViewMyNetwork: whoCanViewMyNetwork ?? this.whoCanViewMyNetwork,
        alertOnProfileVisit: alertOnProfileVisit ?? this.alertOnProfileVisit,
        dateJoined: this.dateJoined,
        lastLogin: this.lastLogin,
        displayZodiacSign: displayZodiacSign ?? this.displayZodiacSign
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowConnectionView': allowConnectionView,
      'id': id.toString(),
      'firstName': firstName,
      'email': email,
      'lastName': lastName,
      'displayName': displayName,
      'postNotification': postNotification,
      'couponNotification': couponNotification,
      'jobNotification': jobNotification,
      'dob': dob?.toIso8601String(),
      'vmcrecord': vmcrecord?.toJson(),
      'username': username,
      'phone': phone?.toMap(),
      'connectionStatus': connectionStatus,
      'connectionId': connectionId,
      'gender': gender?.apiValue,
      'ethnicity': ethnicity?.apiValue,
      'height': {"value": height!.value, "unit": "cm"},
      'weight': {"value": weight, "unit": "kg"},
      'waist': {"value": waist!.value, "unit": "cm"},
      'bust': {"value": bust!.value, "unit": "cm"},
      'feet': {"value": feet!.value, "unit": "cm"},
      'chest': {"value": chest!.value, "unit": "cm"},
      'bio': bio,
      'website': website,
      'hair': hair,
      'eyes': eyes,
      'price': price,
      'locationName': location?.toMap(),
      'profilePictureUrl': profilePictureUrl,
      'thumbnailUrl': thumbnailUrl,
      'isVerified': isVerified,
      'blueTickVerified': blueTickVerified,
      'modelSize': modelSize?.apiValue,
      'isBusinessAccount': isBusinessAccount,
      'userType': userType,
      'label': label,
      'personality': personality,
      'isFollowing': isFollowing,
      'socials': socials?.toMap(),
      'yearsOfExperience': yearsOfExperience,
      'zodiacSign': zodiacSign,
      'whoCanConnectWithMe': whoCanConnectWithMe,
      'whoCanFeatureMe': whoCanFeatureMe,
      'whoCanMessageMe': whoCanMessageMe,
      'whoCanViewMyNetwork': whoCanViewMyNetwork,
      'alertOnProfileVisit': alertOnProfileVisit,
      'dateJoined': dateJoined?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory VAppUserDemo.fromMap(Map<String, dynamic> map, {igNoreEmail = false}) {
    final socials = map['socials'] ?? {"ss": null};
    //print("vmcrecords${map['vmcrecord'] == null}");
    //print('Sociallllslslslsls  map >>>  $socials');
    if (igNoreEmail) {
      map['email'] = '';
    }

    // final ss = UserSocials.fromMap(socials);
    Map<String, dynamic> locationData = {};
    try {
      locationData = Map<String, dynamic>.from((map['location']) ?? {});
      final fn = map['firstName'];
      final ln = map['lastName'];
      return VAppUserDemo(
        allowConnectionView: map['allowConnectionView'],
        id: map['id']!=null?int.tryParse(map['id']) ?? -1:-1,
        firstName: fn==null?null:fn.capitalizeFirstVExt,
        email: map['email'] ,
        lastName: ln==null?null:ln.capitalizeFirstVExt,
        username: map['username']??'',
        displayName: map['displayName'] ??
            '${fn==null?'':fn.capitalizeFirstVExt} ${ln==null?'':ln.capitalizeFirstVExt}',
        phone: map['phone'] != null
            ? PhoneNumberModel.fromMap(map['phone'])
            : null,
        connectionStatus: map['connectionStatus'],
        connectionId: map['connectionId'],
        gender: Gender.genderByApiValue(map['gender'] ?? ''),
        ethnicity: Ethnicity.ethnicityByApiValue(map['ethnicity'] ?? ''),
        modelSize: ModelSize.modelSizeByApiValue(map['size'] ?? ''),
        bio: map['bio'],
        vmcrecord: map['vmcrecord'] != null
            ? VMCRecordModel.fromJson(map['vmcrecord'])
            : null,
        website: map['website'],
        height: map['height'] != null
            ? HeightModel(value: map['height']['value'], unit: "cm")
            : HeightModel(value: "", unit: ""),
        waist: map['waist'] != null
            ? WaistModel(value: map['waist']['value'], unit: "cm")
            : WaistModel(value: "", unit: ""),
        bust: map['bust'] != null
            ? BustModel(value: map['bust']['value'], unit: "cm")
            : BustModel(value: "", unit: ""),
        feet: map['feet'] != null
            ? FeetModel(value: map['feet']['value'], unit: "cm")
            : FeetModel(value: "", unit: ""),
        chest: map['chest'] != null
            ? ChestModel(value: map['chest']['value'], unit: "cm")
            : ChestModel(value: "", unit: ""),
        weight: map['weight'] != null ? map['weight']['value'] : "",
        hair: map['hair'],
        dob: map['dob'] != null ? DateTime.parse(map['dob']) : null,
        eyes: map['eyes'],
        price: map['price'],
        rating: map['rating'],
        location: LocationData.fromMap(locationData),
        postNotification: map['postNotification'],
        couponNotification: map['couponNotification'],
        jobNotification: map['jobNotification'],
        profilePictureUrl: map['profilePictureUrl'] ?? '',
        thumbnailUrl: map['thumbnailUrl'],
        isVerified: (map['isVerified']) ?? false,
        blueTickVerified: (map['blueTickVerified']) ?? false,
        isBusinessAccount: map['isBusinessAccount'],
        userType: map['userType'] ,
        label: map['label'],
        personality: map['personality'],
        isFollowing: map['isFollowing'] ?? false,
        dateJoined: map['dateJoined'] != null
            ? DateTime.parse(map['dateJoined'])
            : null,
        lastLogin:
        map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
        socials:map['socials']==null?null: UserSocials.fromMap(Map<String, dynamic>.from(socials)),
        yearsOfExperience: map['yearsOfExperience'] != null
            ? map['yearsOfExperience']
            : null,
        zodiacSign: map['zodiacSign'] ?? '',
        displayZodiacSign: map['displayStarSign'] ?? '',

        whoCanConnectWithMe: map['whoCanConnectWithMe'] != null
            ? (map['whoCanConnectWithMe'] )
            : "No one",
        whoCanFeatureMe: map['whoCanFeatureMe'] != null
            ? (map['whoCanFeatureMe'] )
            : "No one",
        whoCanMessageMe: map['whoCanMessageMe'] != null
            ? (map['whoCanMessageMe'] )
            : "No one",
        whoCanViewMyNetwork: map['whoCanViewMyNetwork'] != null
            ? (map['whoCanViewMyNetwork'] )
            : "No one",
        alertOnProfileVisit: map['alertOnProfileVisit'] != null
            ? (map['alertOnProfileVisit'])
            : false,
      );
    } catch (e) {
      rethrow;
    }
  }

  factory VAppUserDemo.fromMinimalMap(Map<String, dynamic> map) {
    map['email'] = map['email'] ?? '';
    map['firstName'] = map['firstName'] ?? '';
    map['lastName'] = map['lastName'] ?? '';
    map['isBusinessAccount'] = map['isBusinessAccount'] ?? false;
    map['userType'] = map['userType'] ?? '';
    map['label'] = map['label'] ?? '';

    return VAppUserDemo.fromMap(map);
  }

  String toJson() => json.encode(toMap());

  factory VAppUserDemo.fromJson(String source) =>
      VAppUserDemo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'VAppUserDemo(allowConnectionView: $allowConnectionView, id: $id, firstName: $firstName, email: $email, lastName: $lastName, username: $username, displayName: $displayName, whoCanConnectWithMe: $whoCanConnectWithMe, whoCanFeatureMe: $whoCanFeatureMe, whoCanMessageMe: $whoCanMessageMe, whoCanViewMyNetwork: $whoCanViewMyNetwork, alertOnProfileVisit: $alertOnProfileVisit, dob: $dob, phone: $phone, connectionStatus: $connectionStatus, connectionId: $connectionId, gender: $gender, ethnicity: $ethnicity, bio: $bio, vmcrecord: $vmcrecord, website: $website, weight: $weight, hair: $hair, eyes: $eyes, price: $price, location: $location, profilePictureUrl: $profilePictureUrl, thumbnailUrl: $thumbnailUrl, isVerified: $isVerified, blueTickVerified: $blueTickVerified, modelSize: $modelSize, isBusinessAccount: $isBusinessAccount, userType: $userType, label: $label, zodiacSign: $zodiacSign, displayZodiacSign: $displayZodiacSign, personality: $personality, socials: $socials, isFollowing: $isFollowing, postNotification: $postNotification, jobNotification: $jobNotification, couponNotification: $couponNotification, yearsOfExperience: $yearsOfExperience, dateJoined: $dateJoined, lastLogin: $lastLogin, height: $height, waist: $waist, chest: $chest, feet: $feet, bust: $bust, isLiked: $isLiked)';
  }

  @override
  bool operator ==(covariant VAppUserDemo other) {
    if (identical(this, other)) return true;

    return other.allowConnectionView == allowConnectionView &&
        other.id == id &&
        other.firstName == firstName &&
        other.email == email &&
        other.whoCanConnectWithMe == whoCanConnectWithMe &&
        other.whoCanFeatureMe == whoCanFeatureMe &&
        other.whoCanMessageMe == whoCanMessageMe &&
        other.whoCanViewMyNetwork == whoCanViewMyNetwork &&
        other.alertOnProfileVisit == alertOnProfileVisit &&
        other.lastName == lastName &&
        other.username == username &&
        other.displayName == displayName &&
        other.dob == dob &&
        other.phone == phone &&
        other.connectionStatus == connectionStatus &&
        other.connectionId == connectionId &&
        other.gender == gender &&
        other.ethnicity == ethnicity &&
        other.bio == bio &&
        other.vmcrecord == vmcrecord &&
        other.website == website &&
        other.weight == weight &&
        other.hair == hair &&
        other.eyes == eyes &&
        other.price == price &&
        other.location == location &&
        other.profilePictureUrl == profilePictureUrl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.isVerified == isVerified &&
        other.blueTickVerified == blueTickVerified &&
        other.modelSize == modelSize &&
        other.isBusinessAccount == isBusinessAccount &&
        other.userType == userType &&
        other.label == label &&
        other.zodiacSign == zodiacSign &&
        other.personality == personality &&
        other.socials == socials &&
        other.isFollowing == isFollowing &&
        other.postNotification == postNotification &&
        other.jobNotification == jobNotification &&
        other.couponNotification == couponNotification &&
        other.yearsOfExperience == yearsOfExperience &&
        other.height == height &&
        other.waist == waist &&
        other.chest == chest &&
        other.feet == feet &&
        other.whoCanConnectWithMe == whoCanConnectWithMe &&
        other.whoCanFeatureMe == whoCanFeatureMe &&
        other.whoCanMessageMe == whoCanMessageMe &&
        other.whoCanViewMyNetwork == whoCanViewMyNetwork &&
        other.alertOnProfileVisit == alertOnProfileVisit &&
        other.bust == bust;
  }

  @override
  int get hashCode {
    return allowConnectionView.hashCode ^
    id.hashCode ^
    firstName.hashCode ^
    email.hashCode ^
    lastName.hashCode ^
    username.hashCode ^
    displayName.hashCode ^
    dob.hashCode ^
    phone.hashCode ^
    connectionStatus.hashCode ^
    connectionId.hashCode ^
    gender.hashCode ^
    ethnicity.hashCode ^
    bio.hashCode ^
    vmcrecord.hashCode ^
    website.hashCode ^
    weight.hashCode ^
    hair.hashCode ^
    eyes.hashCode ^
    price.hashCode ^
    location.hashCode ^
    profilePictureUrl.hashCode ^
    thumbnailUrl.hashCode ^
    isVerified.hashCode ^
    blueTickVerified.hashCode ^
    modelSize.hashCode ^
    isBusinessAccount.hashCode ^
    userType.hashCode ^
    label.hashCode ^
    zodiacSign.hashCode ^
    personality.hashCode ^
    socials.hashCode ^
    isFollowing.hashCode ^
    postNotification.hashCode ^
    jobNotification.hashCode ^
    couponNotification.hashCode ^
    yearsOfExperience.hashCode ^
    height.hashCode ^
    waist.hashCode ^
    chest.hashCode ^
    feet.hashCode ^
    whoCanConnectWithMe.hashCode ^
    whoCanFeatureMe.hashCode ^
    whoCanMessageMe.hashCode ^
    whoCanViewMyNetwork.hashCode ^
    alertOnProfileVisit.hashCode ^
    bust.hashCode;
  }
}

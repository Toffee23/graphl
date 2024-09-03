// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vmodel/src/core/utils/logs.dart';

@immutable
class LocationData {
  final double latitude;
  final double longitude;
  final String? streetAddress;
  final String? county;
  final String? city;
  final String? country;
  final String? postalCode;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.streetAddress,
    this.county,
    this.city,
    this.country,
    this.postalCode,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? streetAddress,
    String? state,
    String? city,
    String? country,
    String? postalCode,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      streetAddress: streetAddress ?? this.streetAddress,
      county: state ?? this.county,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'streetAddress': streetAddress,
      'county': county,
      'city': city,
      'country': country,
      'postalCode': postalCode,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    try {
      double lat = 0;
      double lon = 0;
      if (map['latitude'] is String) {
        lat = double.tryParse(map['latitude']) ?? 0.0;
      } else {
        lat = map['latitude'] ?? 0;
      }
      if (map['longitude'] is String) {
        lon = double.tryParse(map['longitude']) ?? 0.0;
      } else {
        lon = map['longitude'] ?? 0;
      }
      return LocationData(
        latitude: lat,
        longitude: lon,
        streetAddress: map['streetAddress'],
        county: map['county'],
        city: map['city'],
        country: map['country'],
        postalCode: map['postalCode'],
      );
    } catch (e, s) {
      logger.e(e.toString(), stackTrace: s);
      rethrow;
    }
  }

  String toJson() => json.encode(toMap());

  factory LocationData.fromJson(String source) => LocationData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => streetAddress == null ? '' : '$streetAddress, $city, $county, $postalCode';

  // @override
  // bool operator ==(covariant LocationData other) {
  //   if (identical(this, other)) return true;

  //   return other.latitude == latitude && other.longitude == longitude && other.locationName == locationName;
  // }

  // @override
  // int get hashCode => latitude.hashCode ^ longitude.hashCode ^ locationName.hashCode;
}

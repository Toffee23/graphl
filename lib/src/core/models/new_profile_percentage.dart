import 'dart:convert';

import 'package:flutter/foundation.dart';

class NewProfilePercentage {
  int percentage;
  List<String> completedFields;
  List<String> uncompletedFields;
  NewProfilePercentage({
    required this.percentage,
    required this.completedFields,
    required this.uncompletedFields,
  });

  NewProfilePercentage copyWith({
    int? percentage,
    List<String>? completedFields,
    List<String>? uncompletedFields,
  }) {
    return NewProfilePercentage(
      percentage: percentage ?? this.percentage,
      completedFields: completedFields ?? this.completedFields,
      uncompletedFields: uncompletedFields ?? this.uncompletedFields,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'percentage': percentage,
      'completedFields': completedFields,
      'uncompletedFields': uncompletedFields,
    };
  }

  factory NewProfilePercentage.fromMap(Map<String, dynamic> map) {
    return NewProfilePercentage(
      percentage: map['percentage']?.toInt() ?? 0,
      completedFields: List<String>.from(map['completedFields']),
      uncompletedFields: List<String>.from(map['uncompletedFields']),
    );
  }

  String toJson() => json.encode(toMap());

  factory NewProfilePercentage.fromJson(String source) =>
      NewProfilePercentage.fromMap(json.decode(source));

  @override
  String toString() =>
      'NewProfilePercentage(percentage: $percentage, completedFields: $completedFields, uncompletedFields: $uncompletedFields)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewProfilePercentage &&
        other.percentage == percentage &&
        listEquals(other.completedFields, completedFields) &&
        listEquals(other.uncompletedFields, uncompletedFields);
  }

  @override
  int get hashCode =>
      percentage.hashCode ^
      completedFields.hashCode ^
      uncompletedFields.hashCode;
}

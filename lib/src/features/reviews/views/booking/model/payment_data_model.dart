// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class PaymentData {
  final String id;
  final double amount;
  final String paymentRef;
  final String status;

  PaymentData({
    required this.id,
    required this.amount,
    required this.paymentRef,
    required this.status,
  });

  PaymentData copyWith({
    String? id,
    double? amount,
    String? paymentRef,
    String? status,
  }) {
    return PaymentData(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentRef: paymentRef ?? this.paymentRef,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'paymentRef': paymentRef,
      'status': status,
    };
  }

  factory PaymentData.fromMap(Map<String, dynamic> map) {
    return PaymentData(
      id: map['id'] as String,
      amount: map['amount'] as double,
      paymentRef: map['paymentRef'] as String,
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentData.fromJson(String source) =>
      PaymentData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PaymentData(id: $id, amount: $amount, paymentRef: $paymentRef, status: $status)';
  }

  @override
  bool operator ==(covariant PaymentData other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.paymentRef == paymentRef &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        paymentRef.hashCode ^
        status.hashCode;
  }
}

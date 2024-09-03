
import 'package:flutter/material.dart';

import '../controller/gig_controller.dart';

@immutable
class BookingIdTab {
  final String id;
  final BookingTab tab;

  BookingIdTab({
    required this.id,
    required this.tab,
  });

  BookingIdTab copyWith({
    String? id,
    BookingTab? tab,
  }) {
    return BookingIdTab(
      id: id ?? this.id,
      tab: tab ?? this.tab,
    );
  }

  @override
  String toString() => 'BookingIdTab(id: $id, tab: $tab)';

  @override
  bool operator ==(covariant BookingIdTab other) {
    if (identical(this, other)) return true;

    return other.id == id && other.tab == tab;
  }

  @override
  int get hashCode => id.hashCode ^ tab.hashCode;
}

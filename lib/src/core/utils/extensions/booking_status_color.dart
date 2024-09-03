
import 'package:flutter/material.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_status.dart';

Color bookingStatusColor(BookingStatus? status, BuildContext context) {
  if (status == null) return Theme.of(context).primaryColor;
  switch (status) {
    case BookingStatus.created:
      // case BookingStatus.:
      return Colors.pinkAccent;
    case BookingStatus.bookingReview:
    case BookingStatus.inProgress:
      return Colors.amber;
    case BookingStatus.bookieCompleted:
      return Colors.blue;
    case BookingStatus.completed:
    case BookingStatus.paymentCompleted:
    case BookingStatus.clientReview:
      return Colors.green;
    case BookingStatus.canceled:
      return Colors.red;
  }
}

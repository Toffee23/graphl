import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/model/service_booking_model.dart';
import 'package:vmodel/src/features/reviews/views/booking/created_gigs/widgets/booking_tile.dart';
import 'package:vmodel/src/features/reviews/views/booking/model/booking_model.dart';

import '../../../../../../vmodel.dart';
import '../controller/gig_controller.dart';

class GigServicesList extends ConsumerStatefulWidget {
  const GigServicesList({
    super.key,
    required this.booking,
    required this.tab,
    required this.services,
  });
  final List<BookingModel> booking;
  final BookingTab tab;
  final List<ServiceBookingModel> services;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GigServicesListState();
}

class _GigServicesListState extends ConsumerState<GigServicesList> {
  final refreshController = RefreshController();
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      onRefresh: () async {
        VMHapticsFeedback.lightImpact();
        ref.read(isRefreshingBookingProvider.notifier).state = true;
        await ref.refresh(serviceBookingProvider.future);
        refreshController.refreshCompleted();
      },
      onLoading: () async {
        await ref.read(serviceBookingProvider.notifier).fetchMoreHandler();
        refreshController.loadComplete();
      },
      child: ListView.separated(
        // shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: widget.booking.length,
        separatorBuilder: (context, index) => SizedBox(
          height: 5,
        ),
        itemBuilder: (context, index) {
          var booking = widget.booking[index];
          final service = widget.services.where((element) => element.id == booking.moduleId.toString()).firstOrNull;
          // logger.i('Service title $')
          // logger.d('Booking name ${booking.title} Module ID ${booking.moduleId}');
          // logger.f(widget.services.where((element) => element.id == booking.moduleId.toString()));
          // logger.f(widget.services.where((element) => element.id == booking.));

          // final displayPrice = (item['price'] as double);

          return ServiceBookingTile(
            booking: booking,
            service: service,
          );

          // return VWidgetsBookingServiceCardWidget(
          //   statusColor: item.status.statusColor(item.processing),
          //   showDescription: false,
          //   onTap: () {
          //     navigateToRoute(
          //         context,
          //         BookingServiceDetail(
          //           service: item,
          //           isCurrentUser: true,
          //           username: 'user?.username',
          //           // username: '${user?.username}',
          //         ));
          //   },
          //   serviceName: item.title,
          //   bannerUrl:
          //       item.banner.isNotEmpty ? item.banner.first.thumbnail : null,
          //   serviceType: item.servicePricing
          //       .tileDisplayName, // Add your service type logic here
          //   serviceLocation: item.serviceType.simpleName,
          //   serviceCharge: item.price,
          //   discount: item.percentDiscount ?? 0,
          //   serviceDescription: item.description,
          //   date: item.createdAt.getSimpleDateOnJobCard(),
          // );
        },
      ),
    );
  }
}

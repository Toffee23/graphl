import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/network/websocket.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/jobs/job_market/model/coupons_model.dart';
import 'package:vmodel/src/features/jobs/job_market/model/job_post_model.dart';

final marketplaceFeedProvider = FutureProvider((ref) async {
  final feedSocket = WSMarketplaceFeed();

  StreamSubscription? feedStream;

  logger.d('Connecting to websocket');
  final connect = await feedSocket.connect();
  if (connect) {
    logger.d('Connected to websocket');
    feedStream = feedSocket.channel?.stream.listen((event) {
      final feedItem = jsonDecode(event);
      logger.w(feedItem);
      try {
        switch (feedItem['feedType']) {
          case 'job':
            ref.read(feedsProvider.notifier).state.add(JobPostModel.fromWebsocket(feedItem));
            break;
          case 'service':
            // ref.read(feedsProvider.notifier).state.add(ServicePackageModel.fromWebsocket(feedItem));
            break;
          case 'coupon':
            ref.read(feedsProvider.notifier).state.add(AllCouponsModel.fromWebsocket(feedItem));
            break;
          default:
        }
        logger.d(ref.read(feedsProvider));
      } catch (e, s) {
        logger.e(e.toString());
        logger.e(s);
        throw 'An error occured';
      }
    }, onError: (e) => logger.e(e.toString()));
  }

  ref.onDispose(() {
    feedStream?.cancel();
    feedSocket.close();
  });
});

final feedsProvider = StateProvider((ref) => []);

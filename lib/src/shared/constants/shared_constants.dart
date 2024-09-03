import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SharedConstants {
  static final refreshController = RefreshController();
  static final scrollController = ScrollController();
  static final feedIndexScrollController = ItemScrollController();
  static final profileRefreshController = RefreshController();
  static final galleryRefreshController = RefreshController();
  static final profileScrollController = ScrollController();
  static final discoverRefreshCOntroller = RefreshController();
  static final discoverScrollController = ScrollController();
}

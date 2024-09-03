import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/shared/shimmer/contentShimmerPage.dart';

import '../../../../vmodel.dart';
import '../../feed/model/feed_model.dart';
import '../controllers/random_video_provider.dart';
import '../widget/fast_video_scroll_physics.dart';
import 'content_screen_each.dart';

bool isUnmute = true;

class ContentViewMain extends ConsumerStatefulWidget {
  const ContentViewMain({Key? key, this.uploadedVideoUrl, this.customVideosList}) : super(key: key);
  final String? uploadedVideoUrl;
  final List<FeedPostSetModel>? customVideosList;

  @override
  ConsumerState<ContentViewMain> createState() => _ContentViewMainState();
}

class _ContentViewMainState extends ConsumerState<ContentViewMain> with TickerProviderStateMixin {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    logger.d('custom Videos ${widget.customVideosList?.isNotEmpty ?? false}');
    _controller = PageController()
      ..addListener(() {
        final maxScroll = _controller.position.maxScrollExtent;
        final currentScroll = _controller.position.pixels;
        final triggerFetchMoreThreshold = maxScroll * 0.6; // Adjust as needed

        if (currentScroll >= triggerFetchMoreThreshold) {
          ref.read(randomVideoProvider(context).notifier).fetchMoreHandler(context);
        }
      });
  }

  @override
  void dispose() {
    // if (isLoading == false) {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var shuffledVideos = ref.watch(randomVideoProvider(context));
    return PopScope(
      canPop: false,
      child: widget.customVideosList != null
          ? GestureDetector(
              onTap: () => dismissKeyboard(),
              child: Scaffold(
                backgroundColor: VmodelColors.blackColor,
                // resizeToAvoidBottomInset: false,
                body: LayoutBuilder(builder: (context, constraints) {
                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _controller,
                    physics: FastContentViewPageViewScrollPhysics(),
                    itemCount: widget.customVideosList!.length,
                    itemBuilder: (context, index) {
                      var valueItem = widget.customVideosList![index];

                      return ContentViewVideoDefault(
                        feedPost: valueItem,
                        controller: _controller,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      );
                    },
                  );
                }),
              ),
            )
          : shuffledVideos.when(
              data: (items) {
                if (items == null || items.length == 0)
                  return const EmptyPage(
                    svgSize: 30,
                    svgPath: VIcons.gridIcon,
                    subtitle: 'No videos available',
                  );
                return GestureDetector(
                  onTap: () => dismissKeyboard(),
                  child: Scaffold(
                    backgroundColor: VmodelColors.blackColor,
                    // resizeToAvoidBottomInset: false,
                    body: LayoutBuilder(builder: (context, constraints) {
                      return PageView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _controller,
                        physics: FastContentViewPageViewScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          var valueItem = items[index];

                          return ContentViewVideoDefault(
                            feedPost: valueItem,
                            controller: _controller,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          );
                        },
                      );
                    }),
                  ),
                );
              },
              error: (err, st) {
                return Text('Error');
              },
              loading: () {
                return ContentShimmerPage(
                  shouldHaveAppBar: false,
                );
              },
            ),
    );
  }
}

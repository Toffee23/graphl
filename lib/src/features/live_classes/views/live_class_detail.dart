import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/services/views/full_view_images.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/bottom_sheets/description_detail_bottom_sheet.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/shimmer/post_shimmer.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/DateTime.dart';
import '../../../shared/empty_page/empty_page.dart';
import '../model/live_class_type.dart';
import '../widgets/live_avatar_class_tile.dart';

class LiveClassDetail extends ConsumerStatefulWidget {
  const LiveClassDetail({
    required this.username,
    required this.liveClass,
    Key? key,
  }) : super(key: key);

  final String username;
  final LiveClassesInput liveClass;

  @override
  ConsumerState<LiveClassDetail> createState() => _LiveClassDetailState();
}

class _LiveClassDetailState extends ConsumerState<LiveClassDetail> {
  bool isSaved = false;
  bool userLiked = false;
  bool userSaved = false;
  int likes = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  ScrollController _listViewController = ScrollController();
  PageController? _pageController;
  int _currentIndex = 0;
  bool isCurrentUser = false;
  final description =
      "I will teach you how I do my nails myself, all you need is the nails paint dry tool for amazon and you’re qualified for my class! If you also want to know anything at all,  please feel free to send me a message! I will do my best to respond";

  @override
  void initState() {
    super.initState();
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    _pageController = PageController(viewportFraction: 1 / 4);

    // //print("data ${serviceData.id}");
  }

  void scrollToCenter(int index) {
    // Calculate the position to scroll to
    double itemExtent =
        SizerUtil.height * .1075; // Replace with your item height
    double targetOffset = itemExtent * index -
        _listViewController.position.viewportDimension / 2 +
        itemExtent / 2;

    // Use the ScrollController to animate the scroll
    _listViewController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: 'Details',
        leadingIcon: const VWidgetsBackButton(),
        trailingIcon: [],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        // padding: const VWidgetsPagePadding.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CarouselSlider(
                  disableGesture: true,
                  items: List.generate(
                    widget.liveClass.banners.length,
                    (index) => Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            navigateToRoute(
                                context,
                                FullViewImages(
                                  images: widget.liveClass.banners,
                                ));
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.liveClass.banners[index],
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            width: double.maxFinite,
                            height: double.maxFinite,
                            fit: BoxFit.cover,
                            // fit: BoxFit.contain,
                            placeholder: (context, url) {
                              // return const PostShimmerPage();
                              return CachedNetworkImage(
                                imageUrl: widget.liveClass.banners[index],
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return const PostShimmerPage();
                                },
                              );
                            },
                            errorWidget: (context, url, error) => EmptyPage(
                              svgSize: 30,
                              svgPath: VIcons.aboutIcon,
                              // title: 'No Galleries',
                              subtitle: 'Tap to refresh',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  carouselController: _controller,
                  options: CarouselOptions(
                    padEnds: false,
                    viewportFraction: 1,
                    aspectRatio: 0.9 / 1, //UploadAspectRatio.portrait.ratio,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      // scrollToCenter(index);
                      _currentIndex = index;
                      setState(() {});
                      // widget.onPageChanged(index, reason);
                    },
                  ),
                ),
                addVerticalSpacing(10),
                Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: PageView.builder(
                      physics: ClampingScrollPhysics(),
                      padEnds: false,
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.liveClass.banners.length,
                      // padding: EdgeInsets.only(right: 10),
                      // separatorBuilder: (context, index) =>
                      //     SizedBox(width: 2),
                      onPageChanged: (value) {
                        // _currentIndex = value;
                        setState(() {});
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // setState(() {
                            // });
                            // scrollToCenter(index);
                            _pageController?.animateToPage(index,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                            _controller.animateToPage(index);
                            _currentIndex = index;
                          },
                          child: Container(
                            // width: 80,/
                            margin:
                                EdgeInsets.only(right: 5, top: 5, bottom: 0),
                            padding: EdgeInsets.all(03),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 3,
                                    color: _currentIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent)),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: widget.liveClass.banners[index],
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  width: 80,
                                  // height: SizerUtil.height * .15,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) {
                                    return const PostShimmerPage();
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
            addVerticalSpacing(20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider(
                  //     thickness: .5, color: Theme.of(context).primaryColor),
                  addVerticalSpacing(10),
                  Card(
                    // color: Theme.of(context).cardColor, //.withOpacity(0.5),
                    // color: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarClassTitleDateTile(
                            title: widget.liveClass.title,
                            profileImage: widget.liveClass.ownersProfilePicture,
                            date: formatTime(widget.liveClass.startTime),
                          ),
                          addVerticalSpacing(12),
                          Row(
                            children: [
                              BulletText(
                                  text: '${widget.liveClass.duration} mins'),
                              Expanded(child: SizedBox(width: 16)),
                              BulletText(
                                  text: widget.liveClass.classDifficulty.name),
                              Expanded(child: SizedBox(width: 16)),
                              BulletText(text: 'Prep Incl.'),
                            ],
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Divider(),
                            ),
                          ),
                          _iconText(VIcons.ticketDiscountOutline,
                              '${VConstants.twoDigitsCurrencyFormatterGB.format(1.99)}'),
                          _iconText(VIcons.categoryTree,
                              widget.liveClass.category?.first ?? ''),
                        ],
                      ),
                    ),
                  ),

                  addVerticalSpacing(16),
                  _headingText(context, title: 'Description'),
                  addVerticalSpacing(16),
                  Card(
                    // color: Theme.of(context).cardColor, //.withOpacity(0.5),
                    // color: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.liveClass.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Divider(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: VWidgetsPrimaryButton(
                              buttonTitle: "View description",
                              onPressed: () {
                                _showBottomSheet(
                                  context,
                                  content: widget.liveClass.description,
                                  title: 'Description',
                                );
                              },
                            ),
                          ),
                          if (widget.liveClass.preparation != null)
                            addVerticalSpacing(8),
                          if (widget.liveClass.preparation != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: VWidgetsPrimaryButton(
                                buttonTitle: "How to prepare",
                                onPressed: () {
                                  context.push('/live_class_prep_page',
                                      extra: widget.liveClass);
                                },
                              ),
                            ),
                          addVerticalSpacing(8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: VWidgetsPrimaryButton(
                              buttonTitle: "Book now",
                              onPressed: () {
                                context.push('/live_class_checkout_page',
                                    extra: widget.liveClass);
                                // navigateToRoute(
                                //     context, LiveClassCheckoutPage());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpacing(32),
          ],
        ),
      ),
    );
  }

  Padding _iconText(String svgIcon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          RenderSvg(
            svgPath: svgIcon,
            svgWidth: 20,
            svgHeight: 20,
          ),
          Expanded(child: SizedBox(width: 32)),
          Text(text),
        ],
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title, required String content, String? briefLink}) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
            title: title,
            content: content,
            briefLink: briefLink,
          );
        });
  }

  Widget _headingText(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              // color: VmodelColors.primaryColor,
            ),
      ),
    );
  }

  Widget iconText({required String assetIcon, required String text}) {
    return Row(
      children: [
        RenderSvg(svgPath: assetIcon, svgHeight: 16, svgWidth: 16),
        addHorizontalSpacing(8),
        Text(
          text,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.7,
                // color: VmodelColors.primaryColor,
                // fontSize: 12,
              ),
        ),
      ],
    );
  }
}

class LiveClassDetailNew extends ConsumerStatefulWidget {
  const LiveClassDetailNew({
    required this.username,
    required this.liveClass,
    Key? key,
  }) : super(key: key);

  final String username;
  final LiveClasses liveClass;

  @override
  ConsumerState<LiveClassDetailNew> createState() => _LiveClassDetailStateNew();
}

class _LiveClassDetailStateNew extends ConsumerState<LiveClassDetailNew> {
  bool isSaved = false;
  bool userLiked = false;
  bool userSaved = false;
  int likes = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  ScrollController _listViewController = ScrollController();
  PageController? _pageController;
  int _currentIndex = 0;
  bool isCurrentUser = false;
  final description =
      "I will teach you how I do my nails myself, all you need is the nails paint dry tool for amazon and you’re qualified for my class! If you also want to know anything at all,  please feel free to send me a message! I will do my best to respond";

  @override
  void initState() {
    super.initState();
    isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(widget.username);
    _pageController = PageController(viewportFraction: 1 / 4);

    // //print("data ${serviceData.id}");
  }

  void scrollToCenter(int index) {
    // Calculate the position to scroll to
    double itemExtent =
        SizerUtil.height * .1075; // Replace with your item height
    double targetOffset = itemExtent * index -
        _listViewController.position.viewportDimension / 2 +
        itemExtent / 2;

    // Use the ScrollController to animate the scroll
    _listViewController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: 'Details',
        leadingIcon: const VWidgetsBackButton(),
        trailingIcon: [],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        // padding: const VWidgetsPagePadding.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CarouselSlider(
                  disableGesture: true,
                  items: List.generate(
                    widget.liveClass.banners.length,
                    (index) => Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            navigateToRoute(
                                context,
                                FullViewImages(
                                  images: widget.liveClass.banners,
                                ));
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.liveClass.banners[index],
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            width: double.maxFinite,
                            height: double.maxFinite,
                            fit: BoxFit.cover,
                            // fit: BoxFit.contain,
                            placeholder: (context, url) {
                              // return const PostShimmerPage();
                              return CachedNetworkImage(
                                imageUrl: widget.liveClass.banners[index],
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                fit: BoxFit.cover,
                                placeholder: (context, url) {
                                  return const PostShimmerPage();
                                },
                              );
                            },
                            errorWidget: (context, url, error) => EmptyPage(
                              svgSize: 30,
                              svgPath: VIcons.aboutIcon,
                              // title: 'No Galleries',
                              subtitle: 'Tap to refresh',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  carouselController: _controller,
                  options: CarouselOptions(
                    padEnds: false,
                    viewportFraction: 1,
                    aspectRatio: 0.9 / 1, //UploadAspectRatio.portrait.ratio,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      // scrollToCenter(index);
                      _currentIndex = index;
                      setState(() {});
                      // widget.onPageChanged(index, reason);
                    },
                  ),
                ),
                addVerticalSpacing(10),
                Container(
                  height: 100,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: PageView.builder(
                      physics: ClampingScrollPhysics(),
                      padEnds: false,
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.liveClass.banners.length,
                      // padding: EdgeInsets.only(right: 10),
                      // separatorBuilder: (context, index) =>
                      //     SizedBox(width: 2),
                      onPageChanged: (value) {
                        // _currentIndex = value;
                        setState(() {});
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // setState(() {
                            // });
                            // scrollToCenter(index);
                            _pageController?.animateToPage(index,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                            _controller.animateToPage(index);
                            _currentIndex = index;
                          },
                          child: Container(
                            // width: 80,/
                            margin:
                                EdgeInsets.only(right: 5, top: 5, bottom: 0),
                            padding: EdgeInsets.all(03),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    width: 3,
                                    color: _currentIndex == index
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent)),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: CachedNetworkImage(
                                  imageUrl: widget.liveClass.banners[index],
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  width: 80,
                                  // height: SizerUtil.height * .15,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) {
                                    return const PostShimmerPage();
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
            addVerticalSpacing(20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider(
                  //     thickness: .5, color: Theme.of(context).primaryColor),
                  addVerticalSpacing(10),
                  Card(
                    // color: Theme.of(context).cardColor, //.withOpacity(0.5),
                    // color: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvatarClassTitleDateTile(
                            title: widget.liveClass.title,
                            profileImage: widget.liveClass.ownersProfilePicture,
                            date: formatTime(widget.liveClass.startTime),
                          ),
                          addVerticalSpacing(12),
                          Row(
                            children: [
                              BulletText(
                                  text: '${widget.liveClass.duration} mins'),
                              Expanded(child: SizedBox(width: 16)),
                              BulletText(
                                  text: widget.liveClass.classDifficulty.name),
                              Expanded(child: SizedBox(width: 16)),
                              BulletText(text: 'Prep Incl.'),
                            ],
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Divider(),
                            ),
                          ),
                          _iconText(VIcons.ticketDiscountOutline,
                              '${VConstants.twoDigitsCurrencyFormatterGB.format(1.99)}'),
                          _iconText(VIcons.categoryTree,
                              widget.liveClass.category?.first ?? ''),
                        ],
                      ),
                    ),
                  ),

                  addVerticalSpacing(16),
                  _headingText(context, title: 'Description'),
                  addVerticalSpacing(16),
                  Card(
                    // color: Theme.of(context).cardColor, //.withOpacity(0.5),
                    // color: Colors.grey.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.liveClass.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Divider(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: VWidgetsPrimaryButton(
                              buttonTitle: "View description",
                              onPressed: () {
                                _showBottomSheet(
                                  context,
                                  content: widget.liveClass.description,
                                  title: 'Description',
                                );
                              },
                            ),
                          ),
                          if (widget.liveClass.preparation != null)
                            addVerticalSpacing(8),
                          if (widget.liveClass.preparation != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: VWidgetsPrimaryButton(
                                buttonTitle: "How to prepare",
                                onPressed: () {
                                  context.push('/live_class_prep_page',
                                      extra: widget.liveClass);
                                },
                              ),
                            ),
                          addVerticalSpacing(8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: VWidgetsPrimaryButton(
                              buttonTitle: "Book now",
                              onPressed: () {
                                context.push('/live_class_checkout_page',
                                    extra: widget.liveClass);
                                // navigateToRoute(
                                //     context, LiveClassCheckoutPage());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpacing(32),
          ],
        ),
      ),
    );
  }

  Padding _iconText(String svgIcon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          RenderSvg(
            svgPath: svgIcon,
            svgWidth: 20,
            svgHeight: 20,
          ),
          Expanded(child: SizedBox(width: 32)),
          Text(text),
        ],
      ),
    );
  }

  Future<dynamic> _showBottomSheet(BuildContext context,
      {required String title, required String content, String? briefLink}) {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DetailBottomSheet(
            title: title,
            content: content,
            briefLink: briefLink,
          );
        });
  }

  Widget _headingText(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              // color: VmodelColors.primaryColor,
            ),
      ),
    );
  }

  Widget iconText({required String assetIcon, required String text}) {
    return Row(
      children: [
        RenderSvg(svgPath: assetIcon, svgHeight: 16, svgWidth: 16),
        addHorizontalSpacing(8),
        Text(
          text,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.7,
                // color: VmodelColors.primaryColor,
                // fontSize: 12,
              ),
        ),
      ],
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/normal_back_button.dart';
import 'package:vmodel/src/shared/shimmer/post_shimmer.dart';

import '../../../../../../res/icons.dart';
import '../../../../../../shared/empty_page/empty_page.dart';

class FullViewImages extends StatefulWidget {
  final List<String?> images;
  const FullViewImages({Key? key, required this.images}) : super(key: key);

  @override
  State<FullViewImages> createState() => _FullViewImagesState();
}

class _FullViewImagesState extends State<FullViewImages> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: const VWidgetsBackButton(
                      buttonColor: Colors.white,
                    ),
                  )),
            ),
          ),
        ),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Center(
            child: CarouselSlider(
              disableGesture: true,
              items: List.generate(
                widget.images.length,
                (index) => Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.images[index].toString(),
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      width: double.maxFinite,
                      height: double.maxFinite,
                      fit: BoxFit.cover,
                      // fit: BoxFit.contain,
                      placeholder: (context, url) {
                        // return const PostShimmerPage();
                        return const PostShimmerPage();
                      },
                      errorWidget: (context, url, error) => EmptyPage(
                        svgSize: 30,
                        svgPath: VIcons.aboutIcon,
                        // title: 'No Galleries',
                        subtitle: 'Tap to refresh',
                      ),
                    ),
                  ],
                ),
              ),
              carouselController: _controller,
              options: CarouselOptions(
                padEnds: false,
                viewportFraction: 1,
                aspectRatio: 0.9 / 0.9, //UploadAspectRatio.portrait.ratio,
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
          ),
          Spacer(),
          if (widget.images.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: DotsIndicator(
                  dotsCount: widget.images.length,
                  position: _currentIndex ?? 0,
                  decorator: DotsDecorator(
                      size: Size(10, 10),
                      activeSize: Size(10, 10),
                      spacing: EdgeInsets.all(3),
                      // color: Color(0XFFEEC18D).withOpacity(0.3),
                      // activeColor: Color(0XFFEEC18D),
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      activeColor: Theme.of(context).primaryColor)),
            ),
          addVerticalSpacing(15)
        ],
      ),
    );
  }
}

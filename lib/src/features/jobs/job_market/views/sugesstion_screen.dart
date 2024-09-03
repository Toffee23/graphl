import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';

class SuggestedScreen extends StatefulWidget {
  const SuggestedScreen({Key? key}) : super(key: key);
  static const routeName = 'allLiveClassesMarketplacePage';

  @override
  State<SuggestedScreen> createState() => _SuggestedScreenState();
}

class _SuggestedScreenState extends State<SuggestedScreen> {
  VideoPlayerController? _controller1;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  VideoPlayerController? _controller4;

  late List<String> videoList;

  @override
  void initState() {
    init();
    super.initState();
    // videoList = [
    //   'https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/4/lives.m3u8',
    //   'https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/3/live.m3u8',
    //   'https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/1/livess.m3u8',
    //   'https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/2/liveess.m3u8',
    // ];
  }

  @override
  void dispose() {
    _controller1?.dispose();
    _controller2?.dispose();
    _controller3?.dispose();
    _controller4?.dispose();
    super.dispose();
  }

  init() async {
    await playVideo1('https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Live.mp4');
  }

  playVideo1(String video) async {
    // _ _controller = VideoPlayerController.asset(video)
    _controller1 = await VideoPlayerController.networkUrl(Uri.parse(video))
      ..initialize().then((_) async {
        _controller1?.setLooping(true);
        _controller1?.setVolume(1);
        _controller1?.play();
        setState(() {});
        await Future.delayed(
          Duration(seconds: 5),
          () async {
            await playVideo2('https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Lives.mp4');
          },
        );
      })
      ..addListener(() {
        if (mounted) {
          // setState(() {});
        }
      });
    setState(() {});
  }

  playVideo2(String video) async {
    // _videoController = VideoPlayerController.asset(video)
    _controller2 = await VideoPlayerController.networkUrl(Uri.parse(video))
      ..initialize().then((_) async {
        _controller2?.setLooping(true);
        _controller2?.setVolume(2);
        _controller2?.play();
        setState(() {});
        await Future.delayed(
          Duration(seconds: 5),
          () async {
            await playVideo3('https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Liveess.mp4');
          },
        );
      })
      ..addListener(() {
        if (mounted) {
          // setState(() {});
        }
      });
    setState(() {});
  }

  playVideo3(String video) async {
    // _ _controller = VideoPlayerController.asset(video)
    _controller3 = await VideoPlayerController.networkUrl(Uri.parse(video))
      ..initialize().then((_) async {
        _controller3?.setLooping(true);
        _controller3?.setVolume(0);
        _controller3?.play();
        setState(() {});
        await Future.delayed(
          Duration(seconds: 5),
          () async {
            await playVideo4('https://vmodel-bucket1.s3.eu-west-2.amazonaws.com/web-resources/Livess.mp4');
          },
        );
      })
      ..addListener(() {
        if (mounted) {
          // setState(() {});
        }
      });
    setState(() {});
  }

  playVideo4(String video) async {
    // _ _controller = VideoPlayerController.asset(video)
    _controller4 = await VideoPlayerController.networkUrl(Uri.parse(video))
      ..initialize().then((_) async {
        _controller4?.setLooping(true);
        _controller4?.setVolume(0);
        _controller4?.play();
        setState(() {});
        await Future.delayed(
          Duration(seconds: 5),
          () async {
            await init();
          },
        );
      })
      ..addListener(() {
        if (mounted) {
          // setState(() {});
        }
      });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        // leading: InkWell(
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        //   child: Center(
        //     child: const RenderSvg(
        //       svgPath: VIcons.forwardIcon,
        //       svgWidth: 15,
        //       svgHeight: 15,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        leading: SizedBox(),

        shadowColor: Colors.transparent,
        title: Text(
          'Welcome to Lives',
          style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          // addVerticalSpacing(55),
          // // addVerticalSpacing(20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 15.0),
          //       child: const RenderSvg(
          //         svgPath: VIcons.forwardIcon,
          //         svgWidth: 15,
          //         svgHeight: 14,
          //         color: Colors.white,
          //       ),
          //     ),
          //     // Center(
          //     //   child: Text(
          //     //     'Welcome to Lives',
          //     //     style: context.textTheme.displayMedium!.copyWith(
          //     //         fontWeight: FontWeight.w800,
          //     //         fontSize: 18,
          //     //         color: Colors.white),
          //     //   ),
          //     // ),
          //     Padding(
          //       padding: const EdgeInsets.only(right: 20.0, left: 10),
          //       child: SizedBox(),
          //     )
          //   ],
          // ),
          // addVerticalSpacing(10),
          Center(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 45),
            child: Text(
              'Learn anything you want, Meet new people and discover new cliques.',
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white54),
            ),
          )),
          addVerticalSpacing(10),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(50)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                  child: Text(
                    'Ongoing',
                    textAlign: TextAlign.start,
                    style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          addVerticalSpacing(10),
          // Expanded(
          //   child: GridView.builder(
          //     physics: NeverScrollableScrollPhysics(),
          //     itemCount: videoList.length,
          //     padding: EdgeInsets.symmetric(horizontal: 10),
          //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //       crossAxisCount: 2,
          //       childAspectRatio: 9 / 13,
          //       mainAxisSpacing: 10,
          //       crossAxisSpacing: 10,
          //     ),
          //     itemBuilder: (context, index) {
          //       var video = videoList[index];
          //       return LayoutBuilder(builder: (context, constraint) {
          //         return ClipRRect(
          //           borderRadius: BorderRadius.circular(10),
          //           child: BetterFeedVideo(
          //             url: video,
          //             height: constraint.minHeight,
          //             width: constraint.minWidth,
          //           ),
          //         );
          //       });
          //     },
          //   ),
          // ),
          Row(
            children: [
              addHorizontalSpacing(15),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height / 3.6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white24),
                      child: !(_controller1?.value.isInitialized ?? false)
                          ? Shimmer.fromColors(
                              baseColor: VmodelColors.surfaceVariantLight.withOpacity(0.2),
                              highlightColor: VmodelColors.onSurfaceVariantLight.withOpacity(0.25),
                              child: Container(
                                height: MediaQuery.sizeOf(context).height / 3.6,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF303030),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayer(
                                _controller1!,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                        Colors.transparent,
                        Colors.black45,
                        Colors.black45,
                        Colors.black45,
                      ])),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white38,
                              backgroundImage: AssetImage('assets/images/photographers/photography.png'),
                            ),
                            addHorizontalSpacing(10),
                            Text(
                              'Suggested',
                              style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                            ),
                            addHorizontalSpacing(10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black45,
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              addHorizontalSpacing(15),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height / 3.6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white24),
                      child: !(_controller2?.value.isInitialized ?? false)
                          ? Shimmer.fromColors(
                              baseColor: VmodelColors.surfaceVariantLight.withOpacity(0.2),
                              highlightColor: VmodelColors.onSurfaceVariantLight.withOpacity(0.25),
                              child: Container(
                                height: MediaQuery.sizeOf(context).height / 3.6,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF303030),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayer(
                                _controller2!,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                        Colors.transparent,
                        Colors.black45,
                        Colors.black45,
                        Colors.black45,
                      ])),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white38,
                              backgroundImage: AssetImage('assets/images/photographers/photography.png'),
                            ),
                            addHorizontalSpacing(10),
                            Text(
                              'Suggested',
                              style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                            ),
                            addHorizontalSpacing(10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black45,
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              addHorizontalSpacing(15),
            ],
          ),
          addVerticalSpacing(15),
          Row(
            children: [
              addHorizontalSpacing(15),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height / 3.6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white24),
                      child: !(_controller3?.value.isInitialized ?? false)
                          ? Shimmer.fromColors(
                              baseColor: VmodelColors.surfaceVariantLight.withOpacity(0.2),
                              highlightColor: VmodelColors.onSurfaceVariantLight.withOpacity(0.25),
                              child: Container(
                                height: MediaQuery.sizeOf(context).height / 3.6,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF303030),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayer(
                                _controller3!,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                        Colors.transparent,
                        Colors.black45,
                        Colors.black45,
                        Colors.black45,
                      ])),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white38,
                              backgroundImage: AssetImage('assets/images/photographers/photography.png'),
                            ),
                            addHorizontalSpacing(10),
                            Text(
                              'Suggested',
                              style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                            ),
                            addHorizontalSpacing(10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black45,
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              addHorizontalSpacing(15),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height / 3.6,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white24),
                      child: !(_controller4?.value.isInitialized ?? false)
                          ? Shimmer.fromColors(
                              baseColor: VmodelColors.surfaceVariantLight.withOpacity(0.2),
                              highlightColor: VmodelColors.onSurfaceVariantLight.withOpacity(0.25),
                              child: Container(
                                height: MediaQuery.sizeOf(context).height / 3.6,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF303030),
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                ),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: VideoPlayer(
                                _controller4!,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                        Colors.transparent,
                        Colors.black45,
                        Colors.black45,
                        Colors.black45,
                      ])),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white38,
                              backgroundImage: AssetImage('assets/images/photographers/photography.png'),
                            ),
                            addHorizontalSpacing(10),
                            Text(
                              'Suggested',
                              style: context.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                            ),
                            addHorizontalSpacing(10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black45,
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              addHorizontalSpacing(15),
            ],
          ),
          addVerticalSpacing(20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: VWidgetsPrimaryButton(
              buttonTitle: 'See upcoming lives',
              onPressed: () {
                context.push(Routes.liveClassesMarketplacePage);
              },
              buttonTitleTextStyle: context.textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black),
              buttonColor: Colors.white,
            ),
          ),

          // Row(
          //   children: [
          //     !( _controller1?.value.isInitialized ?? false)
          //         ? SizedBox()
          //         : Container(
          //             decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(15),
          //                 color: Colors.white24),
          //             child: VideoPlayer(
          //                _controller1!,
          //             ),
          //           ),
          //     !( _controller2?.value.isInitialized ?? false)
          //         ? SizedBox()
          //         : Container(
          //             decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(15),
          //                 color: Colors.white24),
          //             child: VideoPlayer(
          //                _controller2!,
          //             ),
          //           ),
          //   ],
          // ),
        ],
      ),
    );
  }
}

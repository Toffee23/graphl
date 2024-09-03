import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/create_posts/views/create_post.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_video_info/flutter_video_info.dart';

import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../shared/appbar/appbar.dart';
import '../../../shared/buttons/primary_button.dart';
import 'package:video_player/video_player.dart';

final cropProcessingProvider = StateProvider((ref) => false);

class UploadVideoPostPage extends ConsumerStatefulWidget {
  const UploadVideoPostPage({
    super.key,
    required this.videoFile,
  });
  final File videoFile;

  @override
  ConsumerState<UploadVideoPostPage> createState() =>
      _UploadVideoPostPageState();
}

class _UploadVideoPostPageState extends ConsumerState<UploadVideoPostPage> {
  late VideoPlayerController playerController =
      VideoPlayerController.file(File(''));

  bool isLoading = true;
  bool isUnmute = true;

  void initializeController() async {
    WidgetsFlutterBinding.ensureInitialized();

    playerController = VideoPlayerController.file(widget.videoFile);
    await playerController.initialize();

    playerController.setLooping(true);
    playerController.play();
    playerController.setVolume(1);

    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('[0srrt] is initialised ${playerController.value.isInitialized}');

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: VWidgetsAppBar(
        backgroundColor: Colors.transparent,
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: '',
      ),
      body: isLoading
          ? Center(
              child: Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // addVerticalSpacing(40),
                Expanded(
                  child: landingPageCard("LIVE CLASSES",
                      "assets/images/live_images/live_classes_img.png"),
                ),
                Container(
                  height: 10.h,
                  color: Colors.black,
                  padding: EdgeInsets.only(top: 12, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      addVerticalSpacing(16),
                      Flexible(
                        child: VWidgetsPrimaryButton(
                          butttonWidth: 30.w,
                          buttonColor: Colors.white,
                          buttonTitleTextStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: VmodelColors.primaryColor,
                                // fontSize: 11.sp,
                              ),
                          onPressed: () {
                            VMHapticsFeedback.lightImpact();
                            playerController.pause();
                            goBack(context);
                          },
                          enableButton: true,
                          buttonTitle: "Back",
                        ),
                      ),
                      Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isUnmute = !isUnmute;
                              if (isUnmute == false) {
                                playerController.setVolume(0);
                              } else {
                                playerController.setVolume(1);
                              }
                            });
                          },
                          icon: RenderSvg(
                            svgPath: isUnmute == true ? VIcons.unMuteIcon : VIcons.muteIcon,
                            svgHeight: 24,
                            svgWidth: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        child: VWidgetsPrimaryButton(
                          buttonTitle: "Continue",
                          butttonWidth: 30.w,
                          buttonColor: Colors.white,
                          buttonTitleTextStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: VmodelColors.primaryColor,
                                // fontSize: 10.sp,
                              ),
                          onPressed: () {
                            // _chewieController!.pause();
                            // navigateToRoute(context, LiveClassPaymentErrorPage());
                            VMHapticsFeedback.lightImpact();
                            playerController.pause();
                            upload();
                          },
                        ),
                      ),
                      addVerticalSpacing(16),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget landingPageCard(String title, String assetLink) {
    return VisibilityDetector(
      key: Key('vid-ososi398'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        debugPrint(
            'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
        if (visiblePercentage != 100) {
          playerController.pause();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (playerController.value.isPlaying) {
            playerController.pause();
          } else {
            playerController.play();
          }
        },
        child: FittedBox(
          alignment: Alignment.center,
          fit: isWideVideo ? BoxFit.fitWidth : BoxFit.cover,
          // fit: BoxFit.fitWidth,
          child: SizedBox(
            height: playerController.value.size.height,
            width: playerController.value.size.width,
            child: VideoPlayer(
              playerController,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void dispose() {
    print("[xow9p] App disposed");
    playerController.dispose();
    super.dispose();
  }

  Future<List<int>> getVideoDimension() async {
    final videoInfo = FlutterVideoInfo();
    String videoFilePath = widget.videoFile.path;
    var info = (await videoInfo.getVideoInfo(videoFilePath))!;
    return [info.width!, info.height!];
  }

  Future<void> upload() async {
    var dimension = await getVideoDimension();
    navigateToRoute(
      context,
      CreatePostPage(
        images: const [],
        videoFile: widget.videoFile,
        dimension: dimension,
        aspectRatio:
            isWideVideo ? UploadAspectRatio.wide : UploadAspectRatio.portrait,
      ),
    );
  }

  bool get isWideVideo {
    return playerController.value.aspectRatio > 1;
  }
}

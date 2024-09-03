import 'dart:io';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/create_posts/views/create_post.dart';
import 'package:vmodel/src/features/create_posts/controller/media_services.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../res/icons.dart';
import '../../../shared/buttons/text_button.dart';
import '../controller/create_post_controller.dart';
import '../controller/cropped_data_controller.dart';
import '../widgets/crop_widget.dart';
import '../widgets/images_to_crop_stack.dart';
import 'package:video_player/video_player.dart';

final cropProcessingProvider = StateProvider((ref) => false);

class CreatePostWithImagesMediaPicker extends ConsumerStatefulWidget {
  final Route? previousRoute;
  const CreatePostWithImagesMediaPicker({super.key, this.previousRoute});

  @override
  ConsumerState<CreatePostWithImagesMediaPicker> createState() =>
      _CreatePostWithImagesMediaPickerState();
}

class _CreatePostWithImagesMediaPickerState
    extends ConsumerState<CreatePostWithImagesMediaPicker> {
  final picker = ImagePicker();
  final _scrollController = ScrollController();
  bool _isLoadMore = false;
  int _pageCount = 0;
  AssetEntity? selectedEntity;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  Map<AssetEntity, Uint8List> selectedAssetList = {};
  List<AssetEntity> mySelectedImages = [];

  VideoPlayerController? playerController;

  bool isPlaying = false;
  bool isUploading = false;
  bool isMultiple = false;
  bool hideContinue = false;
  String progress = "";
  AssetType? selectedType = null;
  UploadAspectRatio cropAspectRatio = UploadAspectRatio.square;
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');
  final _multiSelectMaxNumber = 10;

  // final maxSizeInBytes = 500 * 1024 * 1024;
  final fiftyMbLimit = 200 * 1024 * 1024;

  int selectedIndex = 0;
  final showLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    MediaServices().loadAlbums(RequestType.common).then(
      (value) {
        try {
          albumList = value;
          selectedAlbum = value[0];
        } catch (e) {}
        setState(() {});

        //LOAD RECENT ASSETS
        MediaServices().loadAssets(selectedAlbum!, _pageCount).then(
          (value) async {
            setState(() {
              // selectedEntity = value[0];

              assetList = value;
            });
            final file = await value[0].file;
            // Check the file extension or MIME type to exclude GIFs
            if (file.path.toLowerCase().endsWith('.gif')) {
              print("GIF file detected, skipping.");
              setState(() {
                hideContinue = true;
              });
              return;
            }

            if (await isFileSizeValid(file!, fiftyMbLimit)) {
              selectedEntity = value[0];
              selectedType = selectedEntity!.type;

              hideContinue = false;

              if (selectedType == AssetType.video) {
                initializeController();
              } else {
                setState(() {});
              }
            } else {
              hideContinue = true;
              setState(() {});
            }
          },
        );
      },
    );
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  /// validate file size based on max required file size
  Future<bool> isFileSizeValid(File file, int maxSizeInBytes) async {
    final size = await file.length();
    return size <= maxSizeInBytes;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    playerController?.dispose();
    super.dispose();
  }

  int roundDouble(double value) {
    double multiplier = .5;
    return (multiplier * value).round();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    isMultiple = ref.watch(isMultipleStateProvider);
    progress = roundDouble(ref.watch(uploadProgressProvider)).toString();

    return Scaffold(
      backgroundColor: Colors.black,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: CloseButton(
          color: Colors.white,
          onPressed: () {
            ref.read(croppedWidgetsProvider.notifier).discardAll();
            goBack(context);
          },
        ),
        centerTitle: true,
        title: SizedBox(
          width: 65,
          child: Text(
            cropAspectRatio.apiValue.toUpperCase(),
            style: context.textTheme.displaySmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: VmodelColors.white),
            textAlign: TextAlign.end,
          ),
        ),
      ),
      // floatingActionButton: GestureDetector(
      //   onTap: () async {
      //     if (isMultiple) {
      //       if (mySelectedImages.length < 1) {
      //         VWidgetShowResponse.showToast(ResponseEnum.warning,
      //             message: 'Select one or more pictures to upload');
      //         return;
      //       }

      //       final myIds = mySelectedImages.map((e) => e.id);
      //       // final results =
      //       await ref.read(croppedWidgetsProvider.notifier).process(myIds);
      //       if (context.mounted) {
      //         navigateToRoute(context,
      //             CreatePostPage(images: [], aspectRatio: cropAspectRatio));
      //       }
      //     } else {
      //       await ref
      //           .read(croppedWidgetsProvider.notifier)
      //           .processSingle(_cropperKey);
      //       if (context.mounted) {
      //         navigateToRoute(context,
      //             CreatePostPage(images: [], aspectRatio: cropAspectRatio));
      //       }
      //     }
      //   },
      //   child: Container(
      //     width: 84,
      //     height: 40,
      //     decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(4),
      //         color: const Color.fromRGBO(238, 238, 238, 1)),
      //     child: Center(
      //       child: Text(
      //         "Continue",
      //         style: context.textTheme.displaySmall!.copyWith(
      //             fontWeight: FontWeight.w500,
      //             fontSize: 16,
      //             color: VmodelColors.greyDeepText),
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            // controller: _scrollController,
            child: controlIcons(height)),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // TOP PREVIEW SECTION FOR IMAGE AND VIDEO
            SliverAppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              backgroundColor: Colors.black,
              pinned: true,
              floating: false,
              toolbarHeight: 0,
              collapsedHeight: null,
              automaticallyImplyLeading: false,
              expandedHeight: MediaQuery.of(context).size.height / 2,
              flexibleSpace: FlexibleSpaceBar(
                background: selectedType == AssetType.video
                    //  VIDEO SELECTION PREVIEW SECTION
                    ? GestureDetector(
                        onTap: () {},
                        child: VisibilityDetector(
                          key: Key('vid-select-page'),
                          onVisibilityChanged: (visibilityInfo) {
                            var visiblePercentage =
                                visibilityInfo.visibleFraction * 100;
                            debugPrint(
                                'Widget ${visibilityInfo.key} is ${visiblePercentage}% visible');
                            if (visiblePercentage != 100) {
                              playerController!.pause();
                            }
                          },
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: playerController!.value.size.width,
                              height: playerController!.value.size.height,
                              child: GestureDetector(
                                onTap: () {
                                  if (isPlaying) {
                                    playerController?.pause();
                                    isPlaying = !isPlaying;
                                  } else {
                                    playerController?.play();
                                    isPlaying = !isPlaying;
                                  }
                                },
                                child: AspectRatio(
                                  aspectRatio:
                                      playerController!.value.aspectRatio,
                                  // Use the VideoPlayer widget to display the video.
                                  child: Stack(children: [
                                    !(playerController?.value.isInitialized ??
                                            false)
                                        ? SizedBox()
                                        : VideoPlayer(playerController!),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    //  IMAGE SELECTION PREVIEW SECTION
                    : SizedBox(
                        height: height * 0.4,
                        width: double.maxFinite,
                        child: selectedEntity == null
                            ? hideContinue
                                ? Center(
                                    child: Image.asset(
                                      "assets/logos/vmodel_logo_transparant.png",
                                      height: 50,
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator.adaptive())
                            : !isMultiple

                                // child: rawSelectedEntityData == null
                                // : stackTop(),
                                ? Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      CropperScreen(
                                        // imageToCrop: rawSelectedEntityData!,
                                        cropperKey: _cropperKey,
                                        entityImage: AssetEntityImage(
                                          selectedEntity!,
                                          isOriginal: false,
                                          filterQuality: FilterQuality.high,
                                          thumbnailSize:
                                              const ThumbnailSize.square(1000),
                                          // fit: BoxFit.cover,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.error,
                                                color: Colors.red,
                                              ),
                                            );
                                          },
                                        ),
                                        aspectRatio: cropAspectRatio,
                                        getCroppedImage: (croppedData) {
                                          // print(
                                          //     '3333333333333333333 ${croppedData.sublist(1, 8)}');
                                        },
                                        crop: () {
                                          // if (isMultiple && selectedEntity != null) {
                                          //   getCroppedData(selectedEntity!, "Crop callback");
                                          // }
                                        },
                                      ),
                                    ],
                                  )
                                : CroppingStack(
                                    key: ValueKey(cropAspectRatio.apiValue),
                                    // views: cropScreens,
                                    // currentIndex: selectedIndex,
                                  ),
                        // : _stackedCropWidgets(),
                        //
                        //   ,),
                      ),
              ),
              titleSpacing: 0,
              primary: false,
            ),
            SliverAppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              backgroundColor: Colors.black,
              pinned: true,
              forceElevated: true,
              primary: false,
              automaticallyImplyLeading: false,
              expandedHeight: 120,
              collapsedHeight: null,
              titleSpacing: 0,
              toolbarHeight: 120,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // CONTINUE BUTTON SECTION
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: (selectedType != AssetType.video)
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.center,
                      children: [
                        if (selectedType != AssetType.video)
                          Container(
                            width: 28,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(04),
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(238, 238, 238, 0.7)),
                            ),
                            child: Center(
                              child: Text(
                                cropAspectRatio.simpleName,
                                style: context.textTheme.displaySmall!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 8,
                                    color: VmodelColors.white),
                              ),
                            ),
                          ),
                        if (selectedType != AssetType.video)
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    onAspectRatioChanged(
                                        UploadAspectRatio.square);
                                  },
                                  child: SvgPicture.asset(
                                    // selected == selectedSquare
                                    cropAspectRatio == UploadAspectRatio.square
                                        ? VIcons.squareFilled
                                        : VIcons.squareOutline,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    onAspectRatioChanged(
                                        UploadAspectRatio.portrait);
                                  },
                                  child: SvgPicture.asset(
                                    // selected == selectedPostrait
                                    cropAspectRatio ==
                                            UploadAspectRatio.portrait
                                        ? VIcons.portraitFilled
                                        : VIcons.portraitOutline,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    onAspectRatioChanged(UploadAspectRatio.pro);
                                  },
                                  child: SvgPicture.asset(
                                    // selected == selectedPro
                                    cropAspectRatio == UploadAspectRatio.pro
                                        ? VIcons.proFilled
                                        : VIcons.proOutline,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    onAspectRatioChanged(
                                        UploadAspectRatio.wide);
                                  },
                                  child: SvgPicture.asset(
                                    // selected == selectedWidescreen
                                    cropAspectRatio == UploadAspectRatio.wide
                                        ? VIcons.wideFilled
                                        : VIcons.wideOutline,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ValueListenableBuilder<bool>(
                          valueListenable: showLoading,
                          builder: (context, value, child) {
                            return VWidgetsTextButton(
                              onPressed: hideContinue
                                  ? null
                                  : () async {
                                      VMHapticsFeedback.lightImpact();

                                      showLoading.value = true;
                                      if (selectedType == AssetType.video) {
                                        await onVideoContinue();
                                      } else {
                                        await onImagesSelected();
                                      }

                                      showLoading.value = false;
                                    },
                              text: 'Continue',
                              loadingIndicatorColor: VmodelColors.white,
                              showLoadingIndicator: value,
                              textStyle: context.textTheme.displaySmall!
                                  .copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: hideContinue
                                          ? VmodelColors.greyDeepText
                                          : mySelectedImages.isEmpty &&
                                                  isMultiple
                                              ? VmodelColors.greyDeepText
                                              : VmodelColors.white),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // RECENT, MULTI SELECT AND CAMERA SCREEN
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            albums(height);
                          },
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  albums(height);
                                },
                                child: IconButton(
                                  icon: const Icon(
                                    Iconsax.sort,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              if (selectedAlbum != null)
                                Text(selectedAlbum!.name,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    )),
                            ],
                          ),
                        ),
                        Expanded(child: addHorizontalSpacing(16)),
                        IconButton(
                          onPressed: () {
                            ref.read(isMultipleStateProvider.notifier).state =
                                !ref.read(isMultipleStateProvider);
                            // isMultiple = !isMultiple;
                            // selectedAssetList.clear();
                            mySelectedImages.clear();

                            if (selectedEntity != null) {
                              final key = GlobalKey(
                                  debugLabel:
                                      '${cropAspectRatio}_${selectedEntity?.id}');
                              final widget =
                                  _buildCropperScreen(selectedEntity!, key);
                              ref
                                  .read(croppedWidgetsProvider.notifier)
                                  .addWidget(
                                      assetId: selectedEntity!.id,
                                      key: key,
                                      widget: widget);
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            ref.watch(isMultipleStateProvider)
                                ? Iconsax.forward_item5
                                : Iconsax.forward_item,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final AssetEntity? entity =
                                await CameraPicker.pickFromCamera(
                              locale: Locale('en'),
                              context,
                              pickerConfig: CameraPickerConfig(
                                  theme: ThemeData(brightness: Brightness.dark),
                                  enableRecording: true,
                                  enableAudio: true,
                                  shouldDeletePreviewFile: true),
                            );
                            if (entity != null) {
                              assetList.insert(0, entity);
                            }
                            setState(() {});
                          },
                          icon: const Icon(
                            Iconsax.camera,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        // addHorizontalSpacing(16),

                        // Expanded(child: addHorizontalSpacing(16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  Future<void> onImagesSelected() async {
    if (ref.read(isMultipleStateProvider)) {
      if (mySelectedImages.isEmpty) {
        VWidgetShowResponse.showToast(ResponseEnum.warning,
            message: 'Select one or more pictures to upload');
        return;
      }

      final myIds = mySelectedImages.map((e) => e.id);

     
      await ref.read(croppedWidgetsProvider.notifier).process(myIds);
      if (context.mounted) {
        // if (widget.previousRoute != null) {
        //   navigateToRoute(
        //     context,
        //     CreatePostPage(
        //       images: const [],
        //       aspectRatio: cropAspectRatio,
        //       previousRoute: widget.previousRoute, // Pass the previous route
        //     ),
        //   );
        // }

        navigateToRoute(context,
            CreatePostPage(images: const [], aspectRatio: cropAspectRatio));
      }
      // final results =
    } else {
      await ref
          .read(croppedWidgetsProvider.notifier)
          .processSingle(_cropperKey);
      if (context.mounted) {
        // if (widget.previousRoute != null) {
        //   navigateToRoute(
        //     context,
        //     CreatePostPage(
        //       images: const [],
        //       aspectRatio: cropAspectRatio,
        //       previousRoute: widget.previousRoute, // Pass the previous route
        //     ),
        //   );
        // }

        navigateToRoute(context,
            CreatePostPage(images: const [], aspectRatio: cropAspectRatio));
      }
    }
  }

  Future<List<int>> getVideoDimension(File file) async {
    final videoInfo = FlutterVideoInfo();
    String videoFilePath = file.path;
    var info = (await videoInfo.getVideoInfo(videoFilePath))!;
    return [info.width!, info.height!];
  }

  Future<void> onVideoContinue() async {
    File? file = await selectedEntity!.file;

    if (selectedEntity!.videoDuration.inSeconds > 300) {
      showAnimatedDialog(
        context: context,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15), // Set your desired border radius here
          ),
          title: Center(
            child: Text(
              'Video Length Limit Exceeded',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Oops! Your video is a bit too long. Keep it under 5 minutes or Upload a shorter video',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 10), // Use SizedBox for vertical spacing
              Flexible(
                child: VWidgetsPrimaryButton(
                  butttonWidth: MediaQuery.of(context).size.width / 1.8,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  enableButton: true,
                  buttonTitle: "OK",
                ),
              ),
            ],
          ),
        ),
      );

      return;
    }

    if (file == null) {
      // responseDialog(context, "Error video file not found");
      SnackBarService().showSnackBar(
          message: "Error video file not found", context: context);
      return;
    }

    final thumbnail = await selectedEntity!.thumbnailData;
    if (thumbnail == null) {
      // responseDialog(context, "Video thumbnail error");
      SnackBarService()
          .showSnackBar(message: "Video thumbnail error", context: context);
      return;
    }
    await ref
        .read(croppedWidgetsProvider.notifier)
        .applyVideoThumbnail([thumbnail]);

    var dimension = await getVideoDimension(file);
    navigateToRoute(
      context,
      CreatePostPage(
        images: const [],
        videoFile: file,
        dimension: dimension,
        aspectRatio:
            isWideVideo ? UploadAspectRatio.wide : UploadAspectRatio.portrait,
      ),
    );
    // navigateToRoute(context, UploadVideoPostPage(videoFile: file));
  }

  bool get isWideVideo {
    if (playerController != null) {
      return playerController!.value.aspectRatio > 1;
    } else {
      return false;
    }
  }

  Widget _buildCropperScreen(AssetEntity image, GlobalKey cropKey) {
    return CropperScreen(
      // imageToCrop: rawSelectedEntityData!,
      key: ValueKey(image.id),
      cropperKey: cropKey,
      entityImage: AssetEntityImage(
        image,
        isOriginal: false,
        filterQuality: FilterQuality.high,
        thumbnailSize: const ThumbnailSize.square(1000),
        // fit: BoxFit.cover,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
            ),
          );
        },
      ),
      aspectRatio: cropAspectRatio,
      getCroppedImage: (croppedData) {
        // print('3333333333333333333 ${croppedData.sublist(1, 8)}');
      },
      crop: () async {
        if (isMultiple && selectedEntity != null) {
          // int indx = mySelectedImages.indexOf(image);
          Cropper.crop(cropperKey: cropKey).then((value) {
            if (value == null) {
              return;
            }
          });
        }
      },
    );
  }

  // Widget _stackedCropWidgets() {
  //   int index = mySelectedImages
  //       .indexWhere((element) => element.id == selectedEntity?.id);
  //   if (index < 0) index = mySelectedImages.length - 1;
  //   return IndexedStack(
  //     // fit: StackFit.expand,
  //     // key: isRemoved ? UniqueKey() : null,
  //     index: index,
  //     alignment: Alignment.center,
  //     children: cropScreens,
  //   );
  //   // }
  // }

  void albums(height) {
    showModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: const Color(0xff101010),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (context) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: albumList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () async {
                // var previousAlbum = selectedAlbum;
                if (selectedAlbum == albumList[index]) {
                  goBack(context);
                  return;
                }
                selectedAlbum = albumList[index];
                _pageCount = 0;
                setState(() {});
                await MediaServices()
                    .loadAssets(selectedAlbum!, _pageCount)
                    .then(
                  (value) {
                    setState(() {
                      assetList = value;
                      if (assetList.isNotEmpty) {
                        selectedEntity = assetList[0];
                      }
                      selectedType = selectedEntity!.type;
                    });
                  },
                );
                initializeController();
                goBack(context);
              },
              title: Text(
                albumList[index].name == "Recent"
                    ? "Gallery"
                    : albumList[index].name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget assetWidget(AssetEntity assetEntity) => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final croppedWidgetState = ref.watch(croppedWidgetsProvider);
          return GestureDetector(
            // onDoubleTap: () {
            //   // if (selectedAssetList.keys.contains(assetEntity)) {
            //   //   setState(() {
            //   //     selectedAssetList.remove(assetEntity);
            //   //   });
            //   if (!isMultiple) return;
            //   if (mySelectedImages.contains(assetEntity)) {
            //     final index = mySelectedImages.indexOf(assetEntity);
            //     mySelectedImages.removeAt(index);
            //     selectedIndex = mySelectedImages.length - 1;
            //     if (selectedIndex >= 0) {
            //       String itemId = mySelectedImages[selectedIndex].id;
            //       ref
            //           .read(croppedWidgetsProvider.notifier)
            //           .remove(index, itemId);
            //     }

            //     selectedEntity = mySelectedImages.last;
            //     // isRemoved = true;
            //   }
            //   setState(() {});
            // },
            onTap: () async {
              final file = await assetEntity.file;

              if (file!.path.toLowerCase().endsWith('.gif')) {
                showAnimatedDialog(
                  context: context,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          15), // Set your desired border radius here
                    ),
                    title: Center(
                      child: Text(
                        'Image Format Error',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'GIF files are not supported',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(
                            height: 10), // Use SizedBox for vertical spacing
                        Flexible(
                          child: VWidgetsPrimaryButton(
                            butttonWidth:
                                MediaQuery.of(context).size.width / 1.8,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            enableButton: true,
                            buttonTitle: "OK",
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                return;
              }

              if (await isFileSizeValid(file, fiftyMbLimit)) {
                selectedEntity = assetEntity;
                hideContinue = false;
                selectedType = selectedEntity!.type;

                // playerController!.dispose();
                if (selectedType == AssetType.video) {
                  ref.read(isMultipleStateProvider.notifier).state = false;
                  if (playerController != null) {
                    playerController!.dispose();
                  }
                  initializeController();
                } else {
                  if (playerController != null) {
                    playerController!.pause();
                    // playerController!.dispose();
                  }
                  setState(() {});
                }
                _scrollController.animateTo(
                  0.0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOutQuart,
                );
              } else {
                showAnimatedDialog(
                  context: context,
                  child: AlertDialog(
                    title: Center(
                        child: Text(
                      'File Size Error',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                    )),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Selected file is larger than 200MB.',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        addVerticalSpacing(10),
                        Flexible(
                          child: VWidgetsPrimaryButton(
                            butttonWidth:
                                MediaQuery.of(context).size.width / 1.8,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            enableButton: true,
                            buttonTitle: "OK",
                          ),
                        ),
                      ],
                    ),
                    // actions: [
                    //   TextButton(
                    //     onPressed: () {
                    //       Navigator.of(context).pop();
                    //     },
                    //     child: Text('OK'),
                    //   ),
                    // ],
                  ),
                );
                return;
              }
              if (isMultiple) {
                if (mySelectedImages.contains(assetEntity)) {
                  final index = mySelectedImages.indexOf(assetEntity);
                  //print('RRRRemoving item at index $index');
                  mySelectedImages.removeAt(index);
                  selectedIndex = mySelectedImages.length - 1;
                  if (selectedIndex >= 0) {
                    String itemId = mySelectedImages[selectedIndex].id;
                    ref
                        .read(croppedWidgetsProvider.notifier)
                        .remove(index, itemId);
                  }

                  if (mySelectedImages.isNotEmpty) {
                    selectedEntity = mySelectedImages.last;
                  }

                  // isRemoved = true;
                } else if (mySelectedImages.length == _multiSelectMaxNumber) {
                  VWidgetShowResponse.showToast(ResponseEnum.warning,
                      message:
                          'Maximum of $_multiSelectMaxNumber pictures can be selected');
                  return;
                } else {
                  // Not already selected and max limit unreached
                  mySelectedImages.add(assetEntity);
                  final key = GlobalKey(
                      debugLabel: '${cropAspectRatio}_${assetEntity.id}');
                  final widget = _buildCropperScreen(assetEntity, key);
                  ref.read(croppedWidgetsProvider.notifier).addWidget(
                      assetId: assetEntity.id, key: key, widget: widget);

                  //global Line
                  selectedIndex = mySelectedImages.indexOf(assetEntity);
                  ref
                      .read(croppedWidgetsProvider.notifier)
                      .updateCurrentIndex(assetEntity.id);
                }

                setState(() {});
              } else {
                mySelectedImages.clear();
                ref.read(croppedWidgetsProvider.notifier).discardAll();
                mySelectedImages.add(assetEntity);
                final key = GlobalKey(
                    debugLabel: '${cropAspectRatio}_${assetEntity.id}');
                final widget = _buildCropperScreen(assetEntity, key);
                ref.read(croppedWidgetsProvider.notifier).addWidget(
                    assetId: assetEntity.id, key: key, widget: widget);
                setState(() {});
              }
              // _getFilePaths();
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: AssetEntityImage(
                    assetEntity,
                    isOriginal: false,
                    thumbnailSize: const ThumbnailSize.square(250),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                if (assetEntity.type == AssetType.video)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              child: Text(
                                _formattedTime(
                                    timeInSecond:
                                        assetEntity.videoDuration.inSeconds),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              Iconsax.video5,
                              color: Colors.red,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    color: assetEntity == selectedEntity
                        // ? Colors.white60
                        ? Colors.white.withOpacity(0.4)
                        : Colors.transparent,
                  ),
                ),
                if (isMultiple == true)
                  Positioned(
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          // color: selectedAssetList.keys.contains(assetEntity) ==
                          color: mySelectedImages.contains(assetEntity)
                              ? Colors.blue
                              : Colors.white12,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            // "${selectedAssetList.keys.toList().indexOf(assetEntity) + 1}",
                            "${mySelectedImages.indexOf(assetEntity) + 1}",
                            style: TextStyle(
                              // color: selectedAssetList.keys
                              //             .contains(assetEntity) ==
                              color: mySelectedImages.contains(assetEntity)
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        // child: ,
      );

  ///formats duration seconds to minutes and seconds
  String _formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  Widget controlIcons(double height) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_isLoadMore)
          const LinearProgressIndicator(
            color: Colors.white,
            backgroundColor: Colors.grey,
          ),
        assetList.isEmpty
            ? const Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // controller: _scrollController,
                itemCount: assetList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 1,
                  crossAxisSpacing: 1,
                ),
                itemBuilder: (context, index) {
                  AssetEntity assetEntity = assetList[index];
                  return assetWidget(assetEntity);
                },
              ),
      ],
    );
  }

  void initializeController() async {
    File? file = await selectedEntity!.file;
    playerController = VideoPlayerController.file(File(file!.path));
    XFile xfile = XFile(file.path);

    await playerController?.initialize().then((value) {
      playerController?.play();
      isPlaying = true;
    });
    playerController!.setVolume(2.0);

    // playerController!.setLooping(true);

    setState(() {});
  }

  void onAspectRatioChanged(UploadAspectRatio ratio) {
    mySelectedImages.clear();
    cropAspectRatio = ratio;
    ref.invalidate(croppedWidgetsProvider);
    if (selectedEntity != null) {
      final key =
          GlobalKey(debugLabel: '${cropAspectRatio}_${selectedEntity?.id}');
      final widget = _buildCropperScreen(selectedEntity!, key);
      ref
          .read(croppedWidgetsProvider.notifier)
          .addWidget(assetId: selectedEntity!.id, key: key, widget: widget);
    }
    setState(() {});
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _isLoadMore = true;

      if (_isLoadMore) {
        _pageCount++;
        MediaServices().loadAssets(selectedAlbum!, _pageCount).then(
          (value) {
            _isLoadMore = false;
            setState(() {
              assetList += value;
            });
          },
        );
        // addItemsToList(pageCount);
      }
      setState(() {});
    }
  }
}

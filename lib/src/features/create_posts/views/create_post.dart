import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';
import 'package:vmodel/src/core/network/graphql_service.dart';
import 'package:vmodel/src/core/utils/enum/service_job_status.dart';
import 'package:vmodel/src/core/utils/enum/service_pricing_enum.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/core/utils/enum/work_location.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/create_posts/widgets/cover_selector.dart';
import 'package:vmodel/src/features/create_posts/widgets/image_with_stack_icons.dart';
import 'package:vmodel/src/features/create_posts/widgets/video_trimmer.dart';
import 'package:vmodel/src/features/create_posts/widgets/video_with_stack_icons.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/discard_editing_controller.dart';
import '../../../core/controller/gmap_places_controller.dart';
import '../../../core/models/app_user.dart';
import '../../../core/utils/enum/album_type.dart';
import '../../../core/utils/extensions/custom_text_input_formatters.dart';
import '../../../shared/response_widgets/toast.dart';
import '../../../shared/text_fields/dropdown_text_normal.dart';
import '../../../shared/text_fields/places_autocomplete_field.dart';
import '../../dashboard/discover/controllers/discover_controller.dart';
import '../../dashboard/new_profile/controller/gallery_controller.dart';
import '../../settings/views/booking_settings/controllers/service_packages_controller.dart';
import '../../settings/views/booking_settings/models/service_package_model.dart';
import '../controller/create_post_controller.dart';
import '../controller/cropped_data_controller.dart';
import '../controller/posts_location_history.dart';
import '../widgets/dialog_create_gallery.dart';
import '../widgets/preview_post.dart';
import 'chip_input_field.dart';

final myStreamProvider = StreamProvider.autoDispose((ref) {
  final myService = ref.watch(authProvider.notifier);
  return myService.getAlbum(myService.state.username!);
});

///[CreatePostPage] handles the creation of post
class CreatePostPage extends ConsumerStatefulWidget {
  final UploadAspectRatio aspectRatio;
  final List<Uint8List> images;
  final File? videoFile;
  final List<int>? dimension;
  final Route? previousRoute;

  const CreatePostPage({
    super.key,
    required this.aspectRatio,
    required this.images,
    this.previousRoute,
    this.dimension,
    this.videoFile,
  });

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  String selectedChip = "Model";
  bool isImageSelected = false;
  bool alertComment = false;
  bool polaroidSwitchValue = false;
  bool showLoadingIndicator = false;
  String dropdownIdentifyValue = "Features";
  GalleryModel? selectedAlbum;
  ServicePackageModel? selectedService;
  AlbumType dropdownPolariodValue = AlbumType.portfolio;

  // final TextEditingController _controller = TextEditingController();
  // final TextEditingController _album = TextEditingController();
  final TextEditingController _caption = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  // late Stream getData;
  bool showUploadOverlay = false;
  int maxNumberOfMentions = 5;
  final List<VAppUser> featured = [];
  final _scrollController = ScrollController();
  String? _selectedLocation;
  int _imageTapCount = 0;
  List<Uint8List> test = [];
  @override
  void initState() {
    super.initState();
    initDiscardProvider();
  }

  initDiscardProvider() {
    //print("selectedAlbum?.id${selectedAlbum?.id}");
    ref.read(discardProvider.notifier).initialState('gallery',
        initial: selectedAlbum?.id, current: selectedAlbum?.id);
    ref
        .read(discardProvider.notifier)
        .initialState('images', initial: test.length, current: test.length);
    ref.read(discardProvider.notifier).initialState('caption',
        initial: _caption.text, current: _caption.text);
    ref.read(discardProvider.notifier).initialState('location',
        initial: _locationController.text, current: _locationController.text);
    ref.read(discardProvider.notifier).initialState('featured',
        initial: featured.length, current: featured.length);
  }

  @override
  void dispose() {
    widget.images;
    // if (mounted) {
    // if (ref.context.mounted) {
    //   ref.invalidate(discardProvider);
    // }
    super.dispose();
  }

  void _incrementCount(List<Uint8List> images) {
    _imageTapCount++;
    //print('+-= Count is $_imageTapCount');
    if (_imageTapCount % 2 == 0) {
// navigateToRoute(context, )
      showAnimatedDialog(
        context: context,
        barrierColor: Colors.black,
        child: PostPreview(
          aspectRatio: widget.aspectRatio,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authNotifier = ref.read(authProvider.notifier);
    // final pst = ref.watch(myStreamProvider);
    final services = ref.watch(userServiceProvider);
    ref.watch(discardProvider);
    final suggestedLocations = ref.watch(suggestedPostLocationProvider);
    //print(widget.images);
    ref.listen(searchUsersProvider, (p, n) {
      // if (n.valueOrNull != null && n.value!.isNotEmpty)
      //print('[pp] ${n.value?.first.username} ${n.value?.length}');
    });
    final uploadPercentage = ref.watch(uploadProgressProvider);
    // final pst = ref.watch(albumsProvider(null));

    // final pst = ;
    // final imagesx = ref.watch(croppedImagesToUploadProviderx);
    final images = ref.watch(croppedImagesProvider);

    // ref.listen(uploadProgressProvider, (prev, next) {
    //   if (next == 0.1 && context.mounted) {
    //     goBack(context);
    //   }
    // });

    return WillPopScope(
      onWillPop: () async {
        return onPopPage(context, ref);
      },
      child: Portal(
        child: Scaffold(
            appBar: VWidgetsAppBar(
              // backgroundColor: VmodelColors.white,
              appBarHeight: 50,
              leadingIcon: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: VWidgetsBackButton(
                  onTap: () {
                    onPopPage(context, ref);
                  },
                ),
              ),
              appbarTitle: "New post",
              customBottom: widget.images.isNotEmpty && uploadPercentage > 0.0
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight + 4),
                      child: LinearProgressIndicator(
                        value:
                            uploadPercentage >= 1.0 ? null : uploadPercentage,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    )
                  : null,
            ),
            body: ref.watch(galleryProvider(null)).when(
              data: (value) {
                final type = polaroidSwitchValue
                    ? AlbumType.polaroid
                    : AlbumType.portfolio;
                final data = value.where((element) {
                  return element.galleryType == type &&
                      element.name.toLowerCase().trim() != "featured";
                }).toList();

                return Padding(
                  padding: EdgeInsets.only(left: 18, right: 18, top: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          // padding: EdgeInsetsDirectional.symmetric(horizontal: 18),
                          children: [
                            addVerticalSpacing(20),
                            if (widget.videoFile == null)
                              SizedBox(
                                height: 142,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (images.isNotEmpty)
                                        ReorderableListView(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            scrollDirection: Axis.horizontal,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            onReorder:
                                                (int oldIndex, int newIndex) {
                                              setState(() {
                                                if (oldIndex < newIndex) {
                                                  newIndex -= 1;
                                                }
                                                final item =
                                                    images.removeAt(oldIndex);
                                                images.insert(newIndex, item);
                                              });
                                            },
                                            children: [
                                              for (int index = 0;
                                                  index < images.length;
                                                  index += 1)
                                                VWidgetsStackImage(
                                                  key: Key('$index'),
                                                  image: MemoryImage(
                                                      images[index]),
                                                  bottomLeftIconOnPressed: () {
                                                    ref
                                                        .read(
                                                            croppedImagesProvider
                                                                .notifier)
                                                        .removeImageAt(index);
                                                  },
                                                  topRightIconOnPressed: () {},
                                                  isImageSelected:
                                                      isImageSelected,
                                                  onTapImage: () {
                                                    // //print(images.length);
                                                    _incrementCount(images);
                                                    setState(() {
                                                      isImageSelected =
                                                          !isImageSelected;
                                                    });
                                                  },
                                                )
                                            ]),
                                      _addMore()
                                    ],
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                height: widget.videoFile != null ? 180 : 142,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.images.isNotEmpty
                                      ? widget.images.length + 1
                                      : images.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == images.length) {
                                      if (widget.videoFile != null) {
                                        return SizedBox.shrink();
                                      } else {
                                        return _addMore();
                                      }
                                    }
                                    if (widget.videoFile != null) {
                                      return Center(
                                        child: VWidgetsStackVideo(
                                          image: MemoryImage(images[index]),
                                          bottomLeftIconOnPressed: () {
                                            ref
                                                .read(croppedImagesProvider
                                                    .notifier)
                                                .removeImageAt(index);
                                          },
                                          topRightIconOnPressed: () {},
                                          isImageSelected: isImageSelected,
                                          onTapImage: () {
                                            if (widget.videoFile != null) {
                                              navigateToRoute(
                                                context,
                                                VideoEditor(
                                                  file: widget.videoFile!,
                                                ),
                                              );
                                              setState(() {
                                                isImageSelected =
                                                    !isImageSelected;
                                              });
                                            }
                                          },
                                          onTapCover: () async {
                                            if (widget.videoFile != null) {
                                              var convertFile =
                                                  await navigateToRoute<
                                                      Uint8List?>(
                                                context,
                                                CoverSelector(
                                                  file: widget.videoFile!,
                                                ),
                                              );
                                              //Final resort to keep things coherent
                                              if (convertFile != null) {
                                                images[index] = convertFile;
                                                setState(() {});
                                              }
                                            }
                                          },
                                        ),
                                      );
                                    } else {
                                      return VWidgetsStackImage(
                                        image: widget.images.isNotEmpty
                                            ? MemoryImage(widget.images[0])
                                            : MemoryImage(images[index]),
                                        bottomLeftIconOnPressed: () {
                                          ref
                                              .read(croppedImagesProvider
                                                  .notifier)
                                              .removeImageAt(index);
                                        },
                                        topRightIconOnPressed: () {},
                                        isImageSelected: isImageSelected,
                                        onTapImage: () {
                                          // //print(images.length);
                                          _incrementCount(images);
                                          setState(() {
                                            isImageSelected = !isImageSelected;
                                          });
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            addVerticalSpacing(25),
                            addVerticalSpacing(10),
                            // const VWidgetsPrimaryTextFieldWithTitle(
                            //   label: "Features",
                            //   hintText: "@",
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Select a gallery',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          // color: VmodelColors.primaryColor,
                                        )),
                                GestureDetector(
                                    onTap: () {
                                      showAnimatedDialog(
                                          context: context,
                                          child: CreateGalleryDialog(
                                              isPolaroid: polaroidSwitchValue));
                                      // builder: ((context) =>

                                      /*
                                              VWidgetsAddAlbumPopUp(
                                                controller: _controller,
                                                popupTitle: "Create a new album",
                                                buttonTitle: "Continue",
                                                textFieldlabel: "Add Name :",
                                                onPressed: () async {
                                                  VLoader.changeLoadingState(true);
                                                  final albumName = _controller
                                                      .text.capitalizeFirst!
                                                      .trim();
                                                  await ref
                                                      .read(albumsProvider(null).notifier)
                                                      .createAlbum(albumName);
                                                  // await ref
                                                  //     .read(albumsProvider.notifier)
                                                  //     .createAlbum(
                                                  //         _controller.text.capitalizeFirst!
                                                  //             .trim(),
                                                  //         userIDPk!)
                                                  //     .then((value) =>
                                                  //         ref.refresh(myStreamProvider));
                                                  if (mounted) {
                                                    goBack(context);
                                                  }

                                                  VLoader.changeLoadingState(false);
                                                },
                                              )));
                                                                  */
                                      // Navigator.pop(context);
                                      // )
                                    },
                                    child: Container(
                                      height: 40,
                                      margin: EdgeInsets.only(bottom: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .secondary,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.add_circle),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Text('Create',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    // color: VmodelColors.primaryColor,
                                                  )),
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                            Row(
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Expanded(
                                //     child: Column(
                                //   children: [
                                //     Chip(
                                //         backgroundColor: Theme.of(context)
                                //             .buttonTheme
                                //             .colorScheme!
                                //             .secondary,
                                //         side: BorderSide.none,

                                //         // labelPadding: EdgeInsets.only(bottom: 20),
                                //         padding:
                                //             EdgeInsets.symmetric(vertical: 13),
                                //         shape: RoundedRectangleBorder(
                                //             borderRadius:
                                //                 BorderRadius.circular(8)),
                                //         label: Center(
                                //             child: Text(
                                //           'Portfolio',
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .displayMedium!
                                //               .copyWith(
                                //                   fontWeight: FontWeight.w600,
                                //                   color: Theme.of(context)
                                //                       .primaryColor
                                //                       .withOpacity(0.7)),
                                //         ))),
                                //     const SizedBox(height: 6),
                                //   ],
                                // )

                                // VWidgetsDropdownNormal(
                                //     value: dropdownPolariodValue,
                                //     items: AlbumType.values,
                                //     validator: (vak) {
                                //       return null;
                                //     },
                                //     onChanged: (val) {
                                //       dropdownPolariodValue = val!;
                                //       if (val == AlbumType.polaroid) {
                                //         polaroidSwitchValue = true;
                                //       } else {
                                //         polaroidSwitchValue = false;
                                //       }
                                //   selectedAlbum = null;
                                //   ref.read(discardProvider.notifier).updateState('gallery', newValue: selectedAlbum?.id);
                                //   setState(() {});
                                // },
                                // itemToString: (val) => val.name.capitalizeFirstVExt),
                                //     ),
                                // const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: FocusScope(
                                    autofocus: true,
                                    child: VWidgetsDropdownNormal(
                                      hintText: "Select",
                                      items: data,
                                      value: selectedAlbum,
                                      validator: (val) {
                                        if (val == null) {
                                          return 'Select gallery';
                                        }
                                        return null;
                                      },
                                      itemToString: (val) => val.name,
                                      onChanged: (val) {
                                        selectedAlbum = val;
                                        ref
                                            .read(discardProvider.notifier)
                                            .updateState('gallery',
                                                newValue: selectedAlbum?.id);
                                        setState(() {
                                          // dropdownIdentifyValue = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            addVerticalSpacing(16),
                            if (services.valueOrNull != null &&
                                services.value!.isNotEmpty)
                              services.maybeWhen(
                                  data: (data) {
                                    List<ServicePackageModel> updated = [
                                      ServicePackageModel(
                                          id: "${data.length + 1}",
                                          price: 0.00,
                                          title: 'Select ',
                                          description: 'Select x',
                                          delivery: 'Select y',
                                          serviceLocation:
                                              WorkLocation.myLocation,
                                          isDigitalContentCreator: true,
                                          hasAdditional: true,
                                          userLiked: false,
                                          userSaved: false,
                                          paused: false,
                                          processing: false,
                                          percentDiscount: 0,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          servicePricing: ServicePeriod.service,
                                          banner: [],
                                          status: ServiceOrJobStatus.active,
                                          serviceTier: []),
                                      ...data
                                    ];
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: FocusScope(
                                            autofocus: true,
                                            child: VWidgetsDropdownNormal<
                                                ServicePackageModel>(
                                              hintText: "Select...",
                                              items: updated,
                                              value: selectedService,
                                              fieldLabel: 'Add a service',
                                              validator: (val) {
                                                return null;
                                              },
                                              isExpanded: true,
                                              itemMaxLines: 1,
                                              itemTextOverflow:
                                                  TextOverflow.ellipsis,
                                              itemToString: (val) => val.title,
                                              onChanged: (val) {
                                                if (selectedService == null &&
                                                    val!.title
                                                        .contains("Select")) {
                                                  // skip
                                                } else if (selectedService !=
                                                    null &&
                                                    val!.title
                                                        .contains("Select")) {
                                                  selectedService = null;
                                                  setState(() {});
                                                } else {
                                                  selectedService = val;
                                                  setState(() {});
                                                }
                                              }
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  orElse: () => SizedBox.shrink()),
                            addVerticalSpacing(16),
                            Text("Features",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .copyWith(
                                        // color: VmodelColors.primaryColor,
                                        fontWeight: FontWeight.w600)),
                            addVerticalSpacing(4),

                            VWidgetChipsField(
                              maxNumberOfChips: maxNumberOfMentions,
                              onChanged: (data) {
                                ref.read(discardProvider.notifier).updateState(
                                    'featured',
                                    initial: featured.length,
                                    newValue: data.length);
                                featured.clear();
                                featured.addAll(data);
                                //print('featured${featured.length}');
                              },
                              suggestions: (query) async {
                                if (query.isEmpty &&
                                    featured.length > maxNumberOfMentions) {
                                  return [];
                                }
                                final users = await ref
                                    .read(discoverProvider.notifier)
                                    .usersFeatured(query);
                                //print('[pps  future completed ${lll.length}');

                                ref.read(discardProvider.notifier).updateState(
                                    'featured',
                                    newValue: users.length);
                                return users;
                                // return searchList.valueOrNull ?? [];
                                // //print(
                                //     '[pp] the search results is ${searchList.value?.length}');
                              },
                            ),

                            addVerticalSpacing(25),

                            PlacesAutocompletionField(
                              controller: _locationController,
                              // placePredictions: placePredictions,
                              // initialValue: _selectedLocation,
                              label: "Location",
                              hintText: "Search location",
                              isFollowerTop: true,
                              onItemSelected: (value) {
                                if (!mounted) return;
                                // WidgetsBinding.instance
                                // .addPostFrameCallback((timeStamp) {
                                // setState(() {
                                _selectedLocation = value['description'];
                                ref.read(discardProvider.notifier).updateState(
                                    'location',
                                    newValue: _selectedLocation);
                                // _isShowAddressPredictions = false;
                                // });
                                // });
                              },
                              postOnChanged: (String value) {
                                ref
                                    .read(discardProvider.notifier)
                                    .updateState('location', newValue: value);
                                if (!mounted) return;
                              },
                            ),

                            suggestedLocations.when(data: (items) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: items.isNotEmpty
                                    ? Center(
                                        child: Container(
                                          height: 40,
                                          // padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: ListView.builder(
                                            itemCount: items.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, left: 5),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _selectedLocation =
                                                        items[index];
                                                    _locationController.text =
                                                        _selectedLocation ?? '';

                                                    ref
                                                        .read(discardProvider
                                                            .notifier)
                                                        .updateState('location',
                                                            newValue:
                                                                _selectedLocation);

                                                    ref
                                                        .read(
                                                            placeSearchQueryProvider
                                                                .notifier)
                                                        .state = '';
                                                    setState(() {});
                                                  },
                                                  child: Chip(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .buttonTheme
                                                            .colorScheme!
                                                            .secondary,
                                                    side: BorderSide.none,
                                                    // labelPadding: EdgeInsets.zero,
                                                    // padding: EdgeInsets.only(left: 0, right: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    // avatar: Icon(Icons.arrow_outward_outlined, size: 20),
                                                    label: Text(items[index]),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              );
                            }, error: (err, stackTrace) {
                              //print('$err, $stackTrace');
                              return SizedBox.shrink();
                            }, loading: () {
                              return Chip(
                                label: Text('Loading'),
                              );
                            }),
                            // VWidgetsPrimaryTextFieldWithTitle(
                            //   label: "Location",
                            //   controller: _location,
                            //   hintText: "Ex. London",
                            // ),
                            addVerticalSpacing(16),
                            // MultiTriggerAutocomplete(
                            //   optionsAlignment: OptionsAlignment.topStart,
                            //   autocompleteTriggers: [
                            //     // Add the triggers you want to use for autocomplete
                            //     AutocompleteTrigger(
                            //       trigger: '@',
                            //       optionsViewBuilder:
                            //           (context, autocompleteQuery, controller) {
                            //         return ColoredBox(color: Colors.blue);
                            //         // return MentionAutocompleteOptions(
                            //         //   query: autocompleteQuery.query,
                            //         //   onMentionUserTap: (user) {
                            //         //     final autocomplete =
                            //         //         MultiTriggerAutocomplete.of(context);
                            //         //     return autocomplete
                            //         //         .acceptAutocompleteOption(user.id);
                            //         //   },
                            //         // );
                            //       },
                            //     ),
                            //     AutocompleteTrigger(
                            //       trigger: '#',
                            //       optionsViewBuilder:
                            //           (context, autocompleteQuery, controller) {
                            //         return ColoredBox(color: Colors.pink);
                            //         // return HashtagAutocompleteOptions(
                            //         //   query: autocompleteQuery.query,
                            //         //   onHashtagTap: (hashtag) {
                            //         //     final autocomplete =
                            //         //         MultiTriggerAutocomplete.of(context);
                            //         //     return autocomplete
                            //         //         .acceptAutocompleteOption(hashtag.name);
                            //         //   },
                            //         // );
                            //       },
                            //     ),
                            //   ],
                            //   // Add the text field widget you want to use for autocomplete
                            //   fieldViewBuilder: (context, controller, focusNode) {
                            //     return Padding(
                            //       padding: const EdgeInsets.all(8.0),
                            //       child: VWidgetsDescriptionTextFieldWithTitle(
                            //         label: "Add Caption",
                            //         hintText: "Start typing...",
                            //         controller: _caption,
                            //         inputFormatters: [
                            //           MaxHashtagsFormatter(),
                            //         ],
                            //         onChanged: (val) {
                            //           ref
                            //               .read(discardProvider.notifier)
                            //               .updateState('caption', newValue: val);
                            //         },
                            //       ),

                            //       // ChatMessageTextField(
                            //       //   focusNode: focusNode,
                            //       //   controller: controller,
                            //       // ),
                            //     );
                            //   },
                            // ),
                            // VWidgetsDescriptionTextFieldWithTitle(
                            //   label: "Add Caption",
                            //   hintText: "Start typing...",
                            //   controller: _caption,
                            //   inputFormatters: [
                            //     MaxHashtagsFormatter(),
                            //   ],
                            //   onChanged: (val) {
                            //     ref
                            //         .read(discardProvider.notifier)
                            //         .updateState('caption', newValue: val);
                            //   },
                            // ),
                            VWidgetsDescriptionTextFieldWithTitle(
                              label: "Add Caption",
                              hintText: "Start typing...",
                              maxLines: 10,
                              controller: _caption,
                              inputFormatters: [
                                MaxHashtagsFormatter(),
                              ],
                              onChanged: (val) {
                                ref
                                    .read(discardProvider.notifier)
                                    .updateState('caption', newValue: val);
                              },
                            ),
                            // addVerticalSpacing(15),
                            // VWidgetsCupertinoSwitchWithText(
                            //   titleText: "Allow comments",
                            //   value: alertComment,
                            //   onChanged: ((p0) {
                            //     setState(() {
                            //       alertComment = !alertComment;
                            //     });
                            //   }),
                            // ),

                            addVerticalSpacing(50),
                          ],
                        ),
                      ),
                      
                      addVerticalSpacing(10),
                      VWidgetsPrimaryButton(
                        buttonTitle: "Share",
                        enableButton: selectedAlbum != null,
                        showLoadingIndicator: showLoadingIndicator,
                        onPressed: () async {
                          //print("Album $selectedAlbum!.id");
                          setState(() {
                            showLoadingIndicator = true;
                          });
                          await Future.delayed(Duration(seconds: 2));

                          if (selectedAlbum != null) {
                            // final selectedFiles = (widget.images).cast<File>();
                            if (widget.videoFile == null) {
                              await uploadImages(images);
                            } else {
                              await uploadVideo();
                            }
                          } else {
                            VWidgetShowResponse.showToast(
                              ResponseEnum.failed,
                              message: "Please select gallery",
                            );
                          }

                          setState(() {
                            showLoadingIndicator = false;
                          });

                          // VLoader.changeLoadingState(false);
                          // Navigator.pop(context);
                        },
                        // enableButton: uploadPercentage >= 0.0 ? false : true,
                      ),
                      addVerticalSpacing(10),
                    ],
                  ),
                );
              },
              error: (error, trace) {
                return Center(
                  child: Text(error.toString()),
                );
              },
              loading: () {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              },
            )),
      ),
    );
  }

  Future<void> uploadVideo() async {
    // ref.read(createPostProvider(null).notifier).createVideoPost(
    //   images: [widget.videoFile!],
    // );

    final taggedUsers = featured.map((e) => e.username).toList();
    ref.read(createPostProvider(null).notifier).createVideoPost(
          albumId: selectedAlbum!.id,
          aspectRatio: widget.aspectRatio,
          images: [
            VideoFileDimension(
              file: widget.videoFile!,
              dimension: widget.dimension,
            )
          ],
          // images: [widget.videoFile!],
          // rawBytes: widget.images.isNotEmpty ? widget.images : images,
          caption: _caption.text.trim(),
          location: _selectedLocation,
          tagged: taggedUsers,
          serviceId: selectedService?.id,
        );
    Navigator.of(context)
      ..pop()
      ..pop();

    context.go('/feedMainUI');

    // if (context.mounted) {
    //   if (widget.previousRoute != null) {
    //     Navigator.of(context).popUntil((route) => route == widget.previousRoute);
    //   }
    //   context.go('/feedMainUI');
    // }
  }

  Future<void> uploadImages(List<Uint8List> images) async {
    final taggedUsers = featured.map((e) => e.username).toList();
    // await ref
    ref.read(createPostProvider(null).notifier).createPost(
          albumId: selectedAlbum!.id,
          aspectRatio: widget.aspectRatio,
          // images: selectedFiles,
          rawBytes: widget.images.isNotEmpty ? widget.images : images,
          caption: _caption.text.trim(),
          location: _selectedLocation,
          tagged: taggedUsers,
          serviceId: selectedService?.id,
        );

    Navigator.of(context)
      ..pop()
      ..pop();

    context.go('/feedMainUI');
    // if (context.mounted) {
    //   if (widget.previousRoute != null) {
    //     debugPrint(widget.previousRoute.toString());
    //     Navigator.of(context).popUntil((route) => route == widget.previousRoute);
    //   }
    //   context.go('/feedMainUI');
    //   // navigateAndRemoveUntilRoute(context, const DashBoardView());
    // }
  }

  Widget _addMore() {
    return Container(
      height: 142,
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade300,
      ),
      child: TextButton(
        onPressed: () async {
          ref.read(isMultipleStateProvider.notifier).state = true;
          goBack(context);
          return

              // SchedulerBinding.instance.addPostFrameCallback((_) {
              //   _scrollController.animateTo(
              //     _scrollController.position.maxScrollExtent,
              //     duration: const Duration(milliseconds: 100),
              //     curve: Curves.ease,
              //   );
              // });
              // _scrollController.animateTo(_scrollController.position.maxScrollExtent,
              //     duration: Duration(milliseconds: 500),
              //     curve: Curves.fastOutSlowIn);

              setState(() {});
        },
        style: TextButton.styleFrom(
          backgroundColor: VmodelColors.vModelprimarySwatch.withOpacity(0.3),
          // foregroundColor: Colors.red,
          // surfaceTintColor: Colors.indigoAccent,
          shape: const CircleBorder(),
          maximumSize: const Size(64, 36),
        ),
        child: Icon(Icons.add, color: VmodelColors.white),
      ),
    );
  }
}

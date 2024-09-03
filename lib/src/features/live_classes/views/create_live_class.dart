import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/helper_functions.dart';
import 'package:vmodel/src/features/live_classes/widgets/request_dialog.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/job_service_section_container.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/discard_editing_controller.dart';
import '../../../core/network/urls.dart';
import '../../../core/utils/exception_handler.dart';
import '../../../core/utils/validators_mixins.dart';
import '../../../res/ui_constants.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/modal_pill_widget.dart';
import '../../../shared/response_widgets/toast.dart';
import '../../../shared/text_fields/description_text_field.dart';
import '../../create_posts/controller/create_post_controller.dart';
import '../../create_posts/repository/create_post_repo.dart';
import '../../settings/views/booking_settings/widgets/service_image_listview.dart';
import '../../settings/views/verification/views/blue-tick/widgets/text_field.dart';
import '../controllers/live_class_selected_banners_provider.dart';
import '../model/live_class_type.dart';
import '../widgets/category_selection_widget.dart';
import '../widgets/marker_textform.dart';
import '../widgets/radio_text.dart';

class CreateLiveClass extends ConsumerStatefulWidget {
  const CreateLiveClass({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateLiveClassState();
}

class _CreateLiveClassState extends ConsumerState<CreateLiveClass> {
  final options = [
    ClassDifficulty.BEGINNER,
    ClassDifficulty.INTERMEDIATE,
    ClassDifficulty.ADVANCED,
  ];
  final _formKey = GlobalKey<FormState>();
  LiveClassType type = LiveClassType.LIVE_CLASS;
  final titleController = TextEditingController();
  final difficultyController = TextEditingController();
  final descriptionController = TextEditingController();
  final ticketController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final _prepController = TextEditingController();
  ClassDifficulty? difficultyValue;
  DateTime? selectedDate = DateTime.now();
  List<String> categories = [];
  bool hasCreated = false;
  List<Widget> timelineTextForm = [];
  List<TextEditingController> markerControllers = [TextEditingController()];
  List<TextEditingController> descriptionControllers = [
    TextEditingController()
  ];
  List<TextEditingController> durationControllers = [TextEditingController()];

  @override
  void initState() {
    super.initState();
    initDiscardProvider();
    timelineTextForm.add(MarkerTextForm(
      markerNumber: 1,
      markerController: markerControllers[0],
      descriptionController: descriptionControllers[0],
      durationController: durationControllers[0],
    ));
  }

  bool get enableContinueButton {
    var banners =
        ref.read(liveClassImagesProvider).map((e) => e.file?.path).toList();
    if (difficultyValue != null &&
        banners.isNotEmpty &&
        double.tryParse(priceController.text) != null &&
        selectedDate != null &&
        int.tryParse(durationController.text) != null &&
        descriptionController.text.isNotEmpty &&
        categories.isNotEmpty) {
      return true;
    }
    return false;
  }

  initDiscardProvider() {
    ref.read(discardProvider.notifier).initialState('title',
        initial: titleController.text, current: titleController.text);
    ref.read(discardProvider.notifier).initialState('difficulty',
        initial: difficultyValue, current: difficultyValue);
    ref.read(discardProvider.notifier).initialState('ticket',
        initial: ticketController.text, current: ticketController.text);
  }

  void createClass() async {
    setState(() {
      hasCreated = true;
    });
    var banners =
        ref.read(liveClassImagesProvider).map((e) => e.file!.path).toList();
    uploadBanners(banners).then((List<String> uploadedBanners) async {
      List<LiveClassTimelineInput> tl = [];
      if (markerControllers[0].text.isNotEmpty) {
        for (var i = 0; i < markerControllers.length; i++) {
          tl.add(LiveClassTimelineInput.fromJson({
            'step': i,
            'title': markerControllers[i].text,
            'description': descriptionControllers[i].text,
            'duration': durationControllers[i].text
          }));
        }
      }
      if (uploadedBanners.isNotEmpty) {
        showAnimatedDialog(
          context: context,
          barrierDismissible: false,
          child: LiveClassLoader(
            liveClassesInput: LiveClassesInput(
              rating: 0,
              title: titleController.text,
              liveType: type,
              description: descriptionController.text,
              price: double.parse(priceController.text),
              startTime: selectedDate!,
              duration: int.parse(durationController.text),
              classDifficulty: difficultyValue!,
              category: categories,
              banners: uploadedBanners,
              timeline: tl,
              preparation:
                  _prepController.text.isNotEmpty ? _prepController.text : null,
              id: '', //ignore
              ownersProfilePicture: '', //ignore
              ownersUsername: '', //ignore
            ),
          ),
        );
      }
    });
  }

  Future<List<String>> uploadBanners(List<String> banners) async {
    ref.read(uploadProgressProvider.notifier).state = 0.01;
    final Either<CustomException, String?> uploadResult;
    final _repository = CreatePostRepository.instance;
    List<Uint8List> rawBytes =
        banners.map((e) => File(e).readAsBytesSync()).toList();
    uploadResult = await _repository.uploadRawBytesList(
        VUrls.postMediaUploadUrl, rawBytes, onUploadProgress: (sent, total) {
      final percentage = sent / total;
    });
    return uploadResult.fold((left) {
      VWidgetShowResponse.showToast(ResponseEnum.failed,
          message: "Error uploading banner");
      setState(() {
        hasCreated = false;
      });
      return [];
    }, (right) async {
      if (right == null) {
        setState(() {
          hasCreated = false;
        });
        VWidgetShowResponse.showToast(ResponseEnum.failed,
            message: "Error uploading banner");
        return [];
      }
      VMHapticsFeedback.mediumImpact();
      final map = json.decode(right);

      final uploadedFilesMap = map["data"] as List<dynamic>;
      if (uploadedFilesMap.isNotEmpty) {
        List<String> objs = uploadedFilesMap
            .map((e) => '${map['base_url']}${e['file_url']}')
            .toList();
        setState(() {
          hasCreated = false;
        });
        return objs;
      } else {
        setState(() {
          hasCreated = false;
        });
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(discardProvider);
    final images = ref.watch(liveClassImagesProvider);
    return WillPopScope(
      onWillPop: () async {
        return onPopPage(context, ref, onDiscard: () {
          ref.invalidate(liveClassImagesProvider);
          ref.invalidate(discardProvider);
          if (context.mounted) {
            goBack(context);
          }
        });
      },
      child: Scaffold(
        appBar: VWidgetsAppBar(
          appbarTitle: "Create a Live",
          leadingIcon: VWidgetsBackButton(
            onTap: () {
              VMHapticsFeedback.lightImpact();
              onPopPage(context, ref, onDiscard: () {
                ref.invalidate(liveClassImagesProvider);
                ref.invalidate(discardProvider);
                if (context.mounted) {
                  goBack(context);
                }
              });
            },
          ),
          trailingIcon: [
            VWidgetsTextButton(
              text: "Create",
              showLoadingIndicator: false,
              onPressed: () async {},
            ),
            addHorizontalSpacing(4),
          ],
        ),
        body: SingleChildScrollView(
          padding: const VWidgetsPagePadding.horizontalSymmetric(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                addVerticalSpacing(20),
                if (images.isNotEmpty)
                  Row(
                    children: [
                      Text("Sample Images",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(1),
                              )),
                    ],
                  ),
                if (images.isNotEmpty) addVerticalSpacing(8),
                if (images.isNotEmpty)
                  Row(
                    children: [
                      Flexible(
                          child: ServiceImageListView(
                        fileImages: images,
                        jobs: true,
                        addMoreImages: () {
                          ref
                              .read(liveClassImagesProvider.notifier)
                              .pickImages();
                        },
                      )),
                    ],
                  ),
                if (images.isEmpty)
                  Row(
                    children: [
                      Text("Live banner(s)",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(1),
                              )),
                    ],
                  ),
                if (images.isEmpty) addVerticalSpacing(8),
                if (images.isEmpty)
                  Flexible(
                    child: Container(
                      width: SizerUtil.width,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .buttonTheme
                              .colorScheme!
                              .secondary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        height: 90,
                        width: 90,
                        // margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).scaffoldBackgroundColor),
                        child: TextButton(
                          onPressed: () => ref
                              .read(liveClassImagesProvider.notifier)
                              .pickImages(),
                          style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .buttonTheme
                                .colorScheme!
                                .secondary,
                            shape: const CircleBorder(),
                            maximumSize: const Size(64, 36),
                          ),
                          child: Icon(Icons.add, color: VmodelColors.white),
                        ),
                      ),
                    ),
                  ),
                addVerticalSpacing(28),
                SectionContainer(
                  topRadius: 24,
                  bottomRadius: 24,
                  height: 50,
                  padding: EdgeInsets.only(left: 18, right: 10),
                  color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: TextRadio<LiveClassType>(
                          text: 'Live Class ${VMString.tradeMark}',
                          value: LiveClassType.LIVE_CLASS,
                          groupValue: type,
                          onTap: () {
                            type = LiveClassType.LIVE_CLASS;
                            setState(() {});
                          },
                        ),
                      ),
                      Flexible(
                        child: TextRadio<LiveClassType>(
                          text: 'Live Session ${VMString.tradeMark}',
                          value: LiveClassType.LIVE_SESSION,
                          groupValue: type,
                          onTap: () {
                            type = LiveClassType.LIVE_SESSION;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                addVerticalSpacing(25),
                VWidgetsTextFieldNormal(
                  // minLines: 1,
                  // maxLines: 3,
                  // isDense: true,
                  // contentPadding:
                  //     const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  onChanged: (val) {
                    ref.read(discardProvider.notifier).updateState('title',
                        initial: titleController.text, newValue: val);
                    setState(() {
                      // if (val.length >= 60) {
                      //   setState(() {
                      //     titleController.clear();
                      //   });
                      // }
                    });
                  },
                  inputFormatters: [],
                  textCapitalization: TextCapitalization.sentences,
                  controller: titleController,
                  // isIncreaseHeightForErrorText: true,
                  // heightForErrorText: 80,
                  labelText: 'Title',
                  hintText: 'Make-up class',
                  validator: (value) =>
                      VValidatorsMixin.isNotEmpty(value, field: "Service name"),
                ),
                addVerticalSpacing(20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Difficulty',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(1),
                                  )),
                          addVerticalSpacing(10),
                          VWidgetsDropDownTextField(
                            maxLength: 60,
                            // fieldLabel: widget.title,
                            // hintText: widget.value == null ? 'select ...' : '',
                            hintText: 'Select',
                            value: difficultyValue?.name.capitalizeFirstVExt,
                            // value: isDefaultSlides ? options.last : options.first,
                            isExpanded: true,
                            suffix: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 28,
                              ),
                            ),
                            // hintStyle: TextStyle(height: 1),
                            labelStyle: TextStyle(height: 1),
                            onChanged: (String val) {
                              setState(() {
                                // dropdownIdentifyValue = val;
                                difficultyValue =
                                    ClassDifficulty.fromString(val);
                              });

                              // //print(widget.value);
                            },
                            options: options
                                .map((e) => e.name.capitalizeFirstVExt)
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    addHorizontalSpacing(10),
                    Flexible(
                      child: VWidgetsTextFieldNormal(
                        onChanged: (val) {
                          ref
                              .read(discardProvider.notifier)
                              .updateState('ticket_price', newValue: val);
                          setState(() {});
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          )
                        ],
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        controller: priceController,
                        labelText: 'Ticket price',
                        hintText: '1.99',
                        validator: (value) => VValidatorsMixin.isNotEmpty(value,
                            field: "Service name"),
                      ),
                    ),
                  ],
                ),
                addVerticalSpacing(16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () async {
                          await _showDatePickerBottomSheet(context)
                              ?.then((value) {
                            if (value != null) {
                              selectedDate = value;
                            }
                          });
                          setState(() {});
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _heading(context, 'Date'),
                            addVerticalSpacing(10),
                            SectionContainer(
                              topRadius: 10,
                              bottomRadius: 10,
                              height: 42,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              color: Theme.of(context)
                                  .buttonTheme
                                  .colorScheme!
                                  .secondary,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(selectedDate.toIso8601DateOnlyString
                                    .toString()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    addHorizontalSpacing(10),
                    Flexible(
                      child: VWidgetsTextFieldNormal(
                        onChanged: (val) {
                          ref
                              .read(discardProvider.notifier)
                              .updateState('ticket_price', newValue: val);
                          setState(() {});
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.sentences,
                        controller: durationController,
                        labelText: 'Length (Minutes)',
                        hintText: '110 min',
                        validator: (value) => VValidatorsMixin.isNotEmpty(value,
                            field: "Service name"),
                      ),
                    ),
                  ],
                ),
                addVerticalSpacing(16),
                CategorySelection(
                  onSelected: (p0) {
                    setState(() {
                      categories = p0;
                    });
                  },
                ),
                addVerticalSpacing(16),
                VWidgetsDescriptionTextFieldWithTitle(
                  maxLines: 5,
                  minLines: 1,
                  controller: descriptionController,
                  label: ' Description',
                  hintText:
                      'Provide a clear and detailed description of the service you are offering.',
                  labelStyle: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: VmodelColors.mainColor),
                  onChanged: (val) {
                    ref.read(discardProvider.notifier).updateState(
                          'description',
                          newValue: val,
                        );
                    setState(() {});
                  },
                ),
                addVerticalSpacing(16),
                _heading(context, 'More Tools'),
                addVerticalSpacing(5),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Stack(children: [
                        GestureDetector(
                            onTap: () {
                              _showPrepBottomSheet(
                                context,
                              );
                            },
                            child: _topCard(
                              'Add a Prep',
                              'Inform your audience on what they need and how to be prepared for your live',
                            )),
                        if (_prepController.text.isNotEmpty)
                          Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: Colors.green, width: 1)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                alignment: Alignment.center,
                                child: Text.rich(TextSpan(
                                    text: 'added ',
                                    style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                    children: [
                                      WidgetSpan(
                                          child: Icon(Icons.check,
                                              color: Colors.green, size: 13))
                                    ])),
                              ))
                      ])),
                      addHorizontalSpacing(16),
                      Expanded(
                          child: Stack(children: [
                        GestureDetector(
                            onTap: () {
                              _showTimeLineBottomSheet(context)
                                  .then((value) => setState(() {}));
                            },
                            child: _topCard(
                              'Add a Timeline',
                              'Elevate your by showing your fans step by step progression when you go live',
                            )),
                        if (markerControllers.first.text.isNotEmpty)
                          Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: Colors.green, width: 1)),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                alignment: Alignment.center,
                                child: Text.rich(TextSpan(
                                    text: 'added ',
                                    style: TextStyle(
                                        fontSize: 9.sp,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                    children: [
                                      WidgetSpan(
                                          child: Icon(Icons.check,
                                              color: Colors.green, size: 13))
                                    ])),
                              ))
                      ])),
                    ],
                  ),
                ),
                addVerticalSpacing(26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: hasCreated
                      ? Center(
                          child: Container(
                            height: 15,
                            width: 15,
                            child: CupertinoActivityIndicator(),
                          ),
                        )
                      : VWidgetsPrimaryButton(
                          onPressed: createClass,
                          buttonTitle: "Create Class",
                          enableButton: enableContinueButton,
                        ),
                ),
                addVerticalSpacing(32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showPrepBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (
          context,
        ) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              constraints: BoxConstraints(
                maxHeight: SizerUtil.height * 0.85,
                minHeight: SizerUtil.height * 0.5,
                minWidth: SizerUtil.width,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVerticalSpacing(15),
                  const Align(
                      alignment: Alignment.center, child: VWidgetsModalPill()),
                  addVerticalSpacing(24),
                  Text(
                    'Add a Prep',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  addVerticalSpacing(16),
                  Flexible(
                    child: Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16)),
                      child: RawScrollbar(
                        mainAxisMargin: 4,
                        crossAxisMargin: -8,
                        thumbVisibility: true,
                        thumbColor:
                            Theme.of(context).primaryColor.withOpacity(0.3),
                        thickness: 4,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  'Tell attendees how to prepare for your live:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                // height: maxLength != null ? 6.h : 6.h,
                                width: 100.0.w,
                                child: TextFormField(
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  controller: _prepController,
                                  minLines: 25,
                                  maxLines: 35,
                                  onChanged: (text) {
                                    setState(() {});
                                    setModalState(() {});
                                  },
                                  cursorColor: Theme.of(context).primaryColor,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(1),
                                      ),
                                  decoration: UIConstants.instance
                                      .inputDecoration(context,
                                          hintText: 'Enter text..',
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  10, 0, 10, 16)),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              VWidgetsPrimaryButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                buttonTitle: "Add",
                                enableButton: _prepController.text.length > 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  addVerticalSpacing(24),
                ],
              ),
            );
          });
        });
  }

  Future<dynamic> _showTimeLineBottomSheet(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (
          context,
        ) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              constraints: BoxConstraints(
                maxHeight: SizerUtil.height * 0.85,
                minHeight: SizerUtil.height * 0.8,
                minWidth: SizerUtil.width,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVerticalSpacing(15),
                  const Align(
                      alignment: Alignment.center, child: VWidgetsModalPill()),
                  addVerticalSpacing(24),
                  Text(
                    'Add a Timeline',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  addVerticalSpacing(16),
                  Flexible(
                    child: Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16)),
                      child: RawScrollbar(
                        mainAxisMargin: 4,
                        crossAxisMargin: -8,
                        thumbVisibility: true,
                        thumbColor:
                            Theme.of(context).primaryColor.withOpacity(0.3),
                        thickness: 4,
                        radius: const Radius.circular(10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  'Inform participants about the stage of your live class.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 5),
                                itemCount: timelineTextForm.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 7,
                                                    child: Text(
                                                        "Marker ${index + 1}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      1),
                                                            )),
                                                  ),
                                                  Flexible(
                                                    flex: 3,
                                                    child: Text("Duration",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .displayMedium!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      1),
                                                            )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            timelineTextForm[index],
                                          ],
                                        ),
                                      ),
                                      if (timelineTextForm.length > 1)
                                        VWidgetsPrimaryButton(
                                          onPressed: () {
                                            timelineTextForm.removeAt(index);
                                            setState(() {});
                                          },
                                          buttonTitle: "Remove",
                                          buttonTitleTextStyle:
                                              Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                    fontWeight: FontWeight.w600,
                                                    // fontSize: 12.sp,
                                                  ),
                                          buttonColor: Theme.of(context)
                                              .buttonTheme
                                              .colorScheme!
                                              .secondary,
                                        ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Divider(
                                        color: Colors.grey.withOpacity(.2),
                                        height: 1,
                                        thickness: 1,
                                      )
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              VWidgetsPrimaryButton(
                                onPressed: () {
                                  var _markerController =
                                      TextEditingController();
                                  var _descriptionController =
                                      TextEditingController();
                                  var _durationController =
                                      TextEditingController();
                                  markerControllers.add(_markerController);
                                  descriptionControllers
                                      .add(_descriptionController);
                                  durationControllers.add(_durationController);
                                  timelineTextForm.add(MarkerTextForm(
                                    markerNumber: timelineTextForm.length + 1,
                                    markerController: _markerController,
                                    descriptionController:
                                        _descriptionController,
                                    durationController: _durationController,
                                  ));
                                  setState(() {});
                                  setModalState(() {});
                                },
                                buttonTitle: "Add New",
                                buttonTitleTextStyle: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      color: Theme.of(context).iconTheme.color,
                                      fontWeight: FontWeight.w600,
                                      // fontSize: 12.sp,
                                    ),
                                buttonColor: Theme.of(context)
                                    .buttonTheme
                                    .colorScheme!
                                    .secondary,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              VWidgetsPrimaryButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                buttonTitle: "Done",
                                enableButton: markerControllers
                                    .where((element) => element.text.isEmpty)
                                    .isEmpty,
                              ),
                              SizedBox(
                                height: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  addVerticalSpacing(24),
                ],
              ),
            );
          });
        });
  }

  Row _heading(BuildContext context, String text) {
    return Row(
      children: [
        Text(
          text,
          style: context.textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<DateTime?>? _showDatePickerBottomSheet(
    BuildContext context,
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
              colorScheme: ColorScheme(
                  primary: Theme.of(context).primaryColor,
                  brightness: Theme.of(context).brightness,
                  onPrimary:
                      Theme.of(context).bottomSheetTheme.backgroundColor ??
                          VmodelColors.primaryColor,
                  error: Theme.of(context).primaryColor,
                  shadow: Theme.of(context).primaryColor,
                  onError: Theme.of(context).primaryColor,
                  secondary: Theme.of(context).primaryColor,
                  onSecondary: Theme.of(context).primaryColor,
                  surface: Theme.of(context).scaffoldBackgroundColor,
                  onSurface: Theme.of(context).primaryColor)),
          child: child!,
        );
      },
    );
  }

  Widget _topCard(String title, String subTitle) {
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),   side: BorderSide(
      //     color: Theme.of(context).shadowColor.withOpacity(0.05),
      //     width: 1.5)),
      child: Container(
        padding: const EdgeInsets.all(10), // 44.w
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 0.3,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey
                  : Colors.grey),
        ),

        height: 160,
        // width: 40.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            addVerticalSpacing(
              15,
            ),
            Text(
              // 'Create a\nclass now',
              title,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
            ),
            addVerticalSpacing(12),
            Flexible(
              child: Text(
                // 'Create your custom class and earn from your skills!',
                subTitle,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 11.sp,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
// Widget _topCard(String title, String subTitle, {double? height}) {
//   return Card(
//     elevation: 3,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),   side: BorderSide(
//         color: Theme.of(context).shadowColor.withOpacity(0.05),
//         width: 1.5)),
//     child: Container(
//       padding: const EdgeInsets.all(10),
//       height: height, // 44.w
//       // width: 40.w,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             // 'Create a\nclass now',
//             title,
//             style: Theme.of(context).textTheme.displayMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               fontSize: 14.sp,
//             ),
//           ),
//           addVerticalSpacing(12),
//           Flexible(
//             child: Text(
//               // 'Create your custom class and earn from your skills!',
//               subTitle,
//               style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                 fontSize: 11.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
}

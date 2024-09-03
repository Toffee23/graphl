import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/share.dart';
import 'package:vmodel/src/features/dashboard/new_profile/profile_features/widgets/profile_picture_widget.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/service_package_model.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/bottom_sheets/confirmation_bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/tile.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/popup_dialogs/input_popup.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/response_widgets/toast_dialogue.dart';
import 'package:vmodel/src/shared/text_fields/primary_text_field.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../core/controller/discard_editing_controller.dart';
import '../../core/utils/extensions/no_special_characters_formatter.dart';
import '../../core/utils/helper_functions.dart';
import '../../res/SnackBarService.dart';
import '../../res/icons.dart';
import '../../shared/buttons/text_button.dart';
import '../../shared/response_widgets/toast.dart';
import '../../shared/switch/primary_switch.dart';
import 'controller/create_coupon_controller.dart';

class AddNewCouponHomepage extends ConsumerStatefulWidget {
  const AddNewCouponHomepage(
    BuildContext context, {
    Key? key,
    this.servicePackage,
    this.couponCode,
    this.coupoTtitle,
    this.couponId,
    this.isUpdate = false,
  }) : super(key: key);
  final ServicePackageModel? servicePackage;
  final String? couponCode;
  final String? coupoTtitle;
  final String? couponId;
  final bool? isUpdate;

  @override
  ConsumerState<AddNewCouponHomepage> createState() =>
      _AddNewServicesHomepageState();
}

class _AddNewServicesHomepageState extends ConsumerState<AddNewCouponHomepage> {
  final codeController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final expiryDateController = TextEditingController();
  final useLimitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isvaluevalid = true;
  bool _showButtonLoader = false;
  bool couponDeleted = false;
  String? _selectedExpiryDate;
  DateFormat formatter = DateFormat('d MMMM yyyy');
  // int _percentDiscount = 0;
  bool _hasExpiryDate = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if ((widget.coupoTtitle != null) && (widget.couponCode != null)) {
      codeController.text = widget.couponCode!;
      titleController.text = widget.coupoTtitle!;
    }
    initDiscardProvider();
  }

  initDiscardProvider() {
    ref.read(discardProvider.notifier).initialState('title',
        initial: titleController.text, current: titleController.text);
    ref.read(discardProvider.notifier).initialState('code',
        initial: codeController.text, current: codeController.text);
  }

  @override
  dispose() {
    // if (ref.context.mounted) {
    //   ref.invalidate(discardProvider);
    // }
    _scrollController.dispose();
    super.dispose();
  }

  void addToListIfNotExist(List<String> options, String value) {
    // if (!options.contains(value)) {
    //   options.insert(options.length - 1, value);
    // }
  }

  String _getOptionFromApiString(List<String> options, String value) {
    return options
        .firstWhere((element) => element.toLowerCase() == value.toLowerCase());
  }

  // bool onPopPage(BuildContext context, Ref ref) {
  //   final hasChanges = ref.read(discardProvider.notifier).checkForChanges();
  //   if (hasChanges) {
  //     // showModal();

  //     showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) {
  //           return DiscardDialog();
  //         });
  //   } else {
  //     goBack(context);
  //   }
  //   return !hasChanges;
  // }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(appUserProvider);
    final user = userState.valueOrNull;
    // final services = ref.watch(userServices(user!.username));
    final myServices = ref.watch(servicePackagesProvider(null));
    ref.watch(discardProvider);

    return Scaffold(
      // appBar: VWidgetsAppBar(
      //   leadingIcon: VWidgetsBackButton(
      //     onTap: () {
      //       onPopPage(context, ref);
      //     },
      //   ),
      //   appbarTitle:
      //       widget.isUpdate! ? "Update coupon" : "Create a new coupon",
      //   trailingIcon: [
      //     VWidgetsTextButton(
      //       text: widget.isUpdate! ? "Update" : "Create",
      //       showLoadingIndicator: _showButtonLoader,
      //       onPressed: () async {
      //         await _onCreateOrUpdate();
      //       },
      //     ),
      //     if (!widget.isUpdate!) addHorizontalSpacing(4),
      //     if (widget.isUpdate!)
      //       IconButton(
      //         onPressed: () async {
      //           VMHapticsFeedback.lightImpact();
      //           showModal();
      //         },
      //         icon: const RenderSvg(svgPath: VIcons.remove),
      //         color: Theme.of(context).iconTheme.color,
      //       ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              addVerticalSpacing(50),
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: VmodelColors.primaryColor,
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 10),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black38,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 2.0),
                                      child: VWidgetsBackButton(
                                        buttonColor: Colors.white,
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    )),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  VUtilsShare.onShare(
                                      context,
                                      [],
                                      "Share coupon code with someone\nCoupon Code:${codeController.text}",
                                      '');
                                },
                                child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black38,
                                    child: Center(
                                      child: RenderSvg(
                                        svgPath: VIcons.shareIcon,
                                        color: VmodelColors.white,
                                        svgWidth: 20,
                                        svgHeight: 20,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        addVerticalSpacing(05),
                        if (codeController.text.isEmpty &&
                            titleController.text.isEmpty)
                          Center(
                            child: Text(
                              "_ _ _ _ _ _",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      color: Colors.grey.withOpacity(0.40),
                                      height: 0),
                            ),
                          ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "${titleController.text} ",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                          ),
                        ),
                        addVerticalSpacing(08),
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            "${codeController.text.toUpperCase()} ",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 24),
                          ),
                        ),
                        Spacer(),
                        if (codeController.text.isEmpty &&
                            titleController.text.isEmpty)
                          Center(
                            child: Text(
                              "Enter coupon details to continue",
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(
                                      color: Colors.white54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                            ),
                          ),
                        addVerticalSpacing(10),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 15,
                    child: ProfilePicture(
                      size: 45,
                      displayName: user?.displayName,
                      url: '${user?.thumbnailUrl}',
                      headshotThumbnail: user?.thumbnailUrl,
                      showBorder: false,
                      profileRing: user?.profileRing,
                    ),
                  )
                ],
              ),
              addVerticalSpacing(20),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // addVerticalSpacing(20),
                    // addVerticalSpacing(16),
                    VWidgetsPrimaryTextFieldWithTitle2(
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 25,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      onChanged: (val) {
                        ref
                            .read(discardProvider.notifier)
                            .updateState('title', newValue: val);
                        setState(() {
                          // if (val.length >= 60) {
                          //   setState(() {
                          //     titleController.clear();
                          //   });
                          // }
                        });
                      },
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      isIncreaseHeightForErrorText: true,
                      heightForErrorText: 80,
                      label: 'Title',
                      hintText: 'PrettyLittleThing 30% Off',
                      // validator: (value) =>
                      //     VValidatorsMixin.isMaximumLengthValid(value, 50,
                      //         field: "Service name"),
                    ),
                    addVerticalSpacing(14),
                    VWidgetsPrimaryTextFieldWithTitle2(
                      maxLength: 30,
                      minLines: 1,
                      maxLines: 3,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      onChanged: (val) {
                        setState(() {
                          codeController.text = val.replaceAll(' ', '');
                          // if (val.length >= 60) {
                          //   setState(() {
                          //     titleController.clear();
                          //   });
                          // }
                        });
                        ref
                            .read(discardProvider.notifier)
                            .updateState('code', newValue: val);
                      },
                      controller: codeController,
                      isIncreaseHeightForErrorText: true,
                      heightForErrorText: 80,
                      label: 'Coupon Code',
                      hintText: 'PLTSUMMER30',
                      formatters: [NoSpecialCharactersFormatter()],
                      // validator: (value) =>
                      //     VValidatorsMixin.isMaximumLengthValid(value, 50,
                      //         field: "Service name"),
                    ),
                    // addVerticalSpacing(32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Expires",
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                  // color: VmodelColors.primaryColor,
                                  fontWeight: FontWeight.w600),
                        ),
                        VWidgetsSwitch(
                          swicthValue: _hasExpiryDate,
                          onChanged: (value) {
                            setState(() {
                              _hasExpiryDate = value;
                            });
                          },
                        ),
                      ],
                    ),
                    addVerticalSpacing(16),
                    if (_hasExpiryDate)
                      VWidgetsPrimaryTextFieldWithTitle2(
                        minLines: 1,
                        // maxLines: 3,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        onChanged: (val) {
                          ref
                              .read(discardProvider.notifier)
                              .updateState('expiry', newValue: val);
                          setState(() {
                            // if (val.length >= 60) {
                            //   setState(() {
                            //     titleController.clear();
                            //   });
                            // }
                          });
                        },
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 10),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData(
                                    colorScheme: ColorScheme(
                                        primary: Theme.of(context).primaryColor,
                                        background: Theme.of(context)
                                                .bottomSheetTheme
                                                .backgroundColor ??
                                            VmodelColors.primaryColor,
                                        brightness:
                                            Theme.of(context).brightness,
                                        onPrimary: Theme.of(context)
                                                .bottomSheetTheme
                                                .backgroundColor ??
                                            VmodelColors.primaryColor,
                                        error: Theme.of(context).primaryColor,
                                        shadow: Theme.of(context).primaryColor,
                                        onBackground:
                                            Theme.of(context).primaryColor,
                                        onError: Theme.of(context).primaryColor,
                                        secondary:
                                            Theme.of(context).primaryColor,
                                        onSecondary:
                                            Theme.of(context).primaryColor,
                                        surface: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        onSurface:
                                            Theme.of(context).primaryColor)),
                                child: child!,
                              );
                            },
                          );
                          if (selectedDate != null) {
                            _selectedExpiryDate =
                                selectedDate.toIso8601String();

                            ref.read(discardProvider.notifier).updateState(
                                'expiry',
                                newValue: _selectedExpiryDate);
                            expiryDateController.text = formatter.format(
                                DateTime.parse(selectedDate
                                    .toIso8601String()
                                    .split("T")[0]));
                            setState(() {});
                          }
                        },
                        shouldReadOnly: true,
                        controller: expiryDateController,
                        isIncreaseHeightForErrorText: true,
                        heightForErrorText: 80,
                        label: 'Expiry (Optional)',
                        hintText: 'Eg: 12 Jul, 2023',
                        // validator: widget.isUpdate!
                        //     ? null
                        //     : (value) => VValidatorsMixin.isNotEmpty(
                        //           value,
                        //           field: "Expiry",
                        //         ),
                      ),
                    // addHorizontalSpacing(16),
                    if (!_hasExpiryDate) addVerticalSpacing(10),

                    VWidgetsPrimaryButton(
                      showLoadingIndicator: _showButtonLoader,
                      buttonTitle: !widget.isUpdate! ? 'Create' : 'Update',
                      enableButton: true,
                      onPressed: () async {
                        await _onCreateOrUpdate();

                        // showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return CreatedSuccessDialogue();
                        //     });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCreateOrUpdate() async {
    bool success = false;
    if (codeController.text.isEmpty || titleController.text.isEmpty) {
      VWidgetShowResponse.showToast(ResponseEnum.warning,
          message: "Please fill all required fields");
      return;
    }

    _toggleButtonLoader();

    // CouponNotifier _createCoupon = CouponNotifier();
    if (widget.isUpdate!) {
      success = await ref.read(userCouponsProvider(null).notifier).updateCoupon(
            code: codeController.text.toString(),
            title: titleController.text.toString(),
            couponId: widget.couponId!,
            useLimit: useLimitController.text.isNotEmpty
                ? int.parse(useLimitController.text.trim())
                : null,
            expiryDate: _selectedExpiryDate ?? null,
          );
      toastDialoge(
          text: success ? "Coupon updated successful" : "Failed to update",
          context: context,
          toastLength: Duration(seconds: 2));
    } else {
      // await Future.delayed(Duration(seconds: 6));
      success = await ref.read(userCouponsProvider(null).notifier).createCoupon(
            // final data = await _createCoupon.publishCoupon(
            code: codeController.text.toString(),
            title: titleController.text.toString(),
            expiryDate: _hasExpiryDate ? _selectedExpiryDate : null,
            useLimit: useLimitController.text.isNotEmpty
                ? int.parse(useLimitController.text.trim())
                : null,
          );
    }

    _toggleButtonLoader();
    success
        ? SnackBarService().showSnackBar(
            message: "Coupon successfully created", context: context)
        // showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return CreatedSuccessDialogue();
        //         })
        : toastDialoge(
            text: "Failed to created coupon",
            context: context,
            toastLength: Duration(seconds: 1));

    if (context.mounted) {
      goBack(context);
    }
  }

  void _toggleButtonLoader() {
    _showButtonLoader = !_showButtonLoader;
    setState(() {});
  }
  // _isDigitalContent() {}

  Future<String?> showInputPopup(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
        context: context,
        builder: ((context) => VWidgetsInputPopUp(
              popupTitle: title,
              popupField: TextFormField(
                decoration: const InputDecoration(hintText: 'Please specify'),
                controller: controller,
                // decoration: (InputDecoration(hintText: '')),
              ),
              onPressedYes: () async {
                Navigator.pop(context, controller.text.trim());
              },
            )));
    return result;
  }

  void showModal() {
    bool showLoader = false;
    showModalBottomSheet<Widget>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: VWidgetsConfirmationBottomSheet(
              title: "Are you sure you want to delete?",
              actions: [
                // Follow
                // Stack(
                //   children: [
                //     VWidgetsPrimaryButton(
                //       showLoadingIndicator: showLoader,
                //       onPressed: () async {
                //         setState(() {
                //           showLoader = true;
                //         });
                //         await ref
                //             .read(userCouponsProvider(null).notifier)
                //             .deleteCoupon(widget.couponId!);
                //         goBack(context);
                //         goBack(context);
                //       },
                //       buttonTitle: "Delete",
                //       buttonTitleTextStyle:
                //           Theme.of(context).textTheme.displayMedium,
                //       buttonColor: Theme.of(context).scaffoldBackgroundColor,
                //     ),
                //   ],
                // ),

                VWidgetsTextButton(
                  text: 'Delete',
                  showLoadingIndicator: showLoader,
                  onPressed: () async {
                    setState(() {
                      showLoader = true;
                    });
                    await ref
                        .read(userCouponsProvider(null).notifier)
                        .deleteCoupon(widget.couponId!);
                    goBack(context);
                    goBack(context);
                  },
                ),
                // if (!showLoader)
                const Divider(
                  thickness: 0.5,
                ),
                // Connect
                // if (!showLoader)
                VWidgetsBottomSheetTile(
                    onTap: () {
                      if (!showLoader) popSheet(context);
                    },
                    message: 'Cancel')
              ],
            ),
          );
        });
      },
    );
  }
}

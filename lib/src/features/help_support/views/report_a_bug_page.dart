import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/help_support/controllers/report_bug_controller.dart';
import 'package:vmodel/src/features/help_support/controllers/report_image_controller.dart';
import 'package:vmodel/src/features/help_support/widgets/image_list_view.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/text_fields/description_text_field.dart';

class ReportABugHomePage extends ConsumerStatefulWidget {
  const ReportABugHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportABugHomePageState();
}

class _ReportABugHomePageState extends ConsumerState<ReportABugHomePage> {
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _phoneTypeController = TextEditingController();
  TextEditingController _osVersionController = TextEditingController();

  final showLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(reportImagesProvider);

    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Report a bug",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  VWidgetsDescriptionTextFieldWithTitle(
                    hintText: "Share as much details as possible...",
                    minLines: 7,
                    controller: _detailsController,
                    onChanged: (text){
                      if(mounted) setState(() {});
                    },
                  ),

                  addVerticalSpacing(8),

                  if (images.isNotEmpty)...[
                    Row(
                      children: [
                        Flexible(
                            child: ReportImageListView(
                              fileImages: images,
                              addMoreImages: () {
                                ref.read(reportImagesProvider.notifier).pickImages(1);
                              },
                            )),
                      ],
                    ),
                  ],

                  if (images.isEmpty)...[
                    Row(
                      children: [
                        Text("Attach image",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                            )),
                      ],
                    ),
                    Container(
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
                              .read(reportImagesProvider.notifier)
                              .pickImages(1),
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
                  ],

                  addVerticalSpacing(20),
                  /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      VWidgetsPrimaryTextFieldWithTitle2(
                        label: "Phone Type",
                        hintText: "iPhone 13 Pro Max",
                        minWidth: MediaQuery.of(context).size.width * .4,
                        maxLines: 1,
                        controller: _phoneTypeController,
                        onChanged: (text){
                          if(mounted) setState(() {});
                        },
                      ),
                      VWidgetsPrimaryTextFieldWithTitle2(
                        label: "OS verison",
                        hintText: "iOS verion 15.4",
                        minWidth: MediaQuery.of(context).size.width * .4,
                        maxLines: 1,
                        controller: _osVersionController,
                        onChanged: (text){
                          if(mounted) setState(() {});
                        },
                      ),
                    ],
                  )*/
                ],
              ),
            )),
            addVerticalSpacing(10),

            ValueListenableBuilder(
                valueListenable: showLoading,
                builder: (context, value, _) {
                  return VWidgetsPrimaryButton(
                    showLoadingIndicator: value,
                    enableButton: _detailsController.text.isNotEmpty,
                    buttonTitle: "Submit",
                    onPressed: () async {
                      showLoading.value = true;
                      if(_detailsController.text.isEmpty) return;
                      var result;
                      if(images.isNotEmpty) {
                        result =
                        await ref.read(ticketProvider.notifier).reportIssue(
                          images: images.map((e) => e.file).toList(),
                            report: _detailsController.text,
                            subject: "Bug report");
                      } else {
                        result =
                        await ref.read(ticketProvider.notifier).reportIssueWithoutImage(
                            report: _detailsController.text,
                            subject: "Bug report");
                      }
                      showLoading.value = false;
                      //print(result);
                      if (!result){
                        //Report failed
                        return;
                      } else {
                        _detailsController.clear();

                        Navigator.of(context)
                          ..pop();

                        VMHapticsFeedback.lightImpact();
                        // responseDialog(context, "Bug reported");
                        SnackBarService().showSnackBar(
                            message: "Bug reported",
                            context: context);
                      }

                    },
                  );
                }
            ),

            addVerticalSpacing(40),
          ],
        ),
      ),
    );
  }
}

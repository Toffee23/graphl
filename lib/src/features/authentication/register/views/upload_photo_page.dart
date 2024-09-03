import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/controller/app_user_controller.dart';
import '../../../../core/utils/helper_functions.dart';
import '../provider/user_types_controller.dart';

class SignUpUploadPhotoPage extends ConsumerStatefulWidget {
  const SignUpUploadPhotoPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<SignUpUploadPhotoPage> createState() => _OnboardingPhotoPageState();
}

class _OnboardingPhotoPageState extends ConsumerState<SignUpUploadPhotoPage> {
  bool isUploaded = false;
  String uploadButtonTitle = 'Upload';
  String? _imageFilename;

  File? _image;
  final isShowButtonLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final isBusinessAccount = ref.watch(isAccountTypeBusinessProvider);

    return Scaffold(
      // backgroundColor: VmodelColors.background,
      appBar: AppBar(
        leading: const VWidgetsBackButton(),
        // backgroundColor: VmodelColors.background,

        iconTheme: IconThemeData(color: VmodelColors.mainColor),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBusinessAccount ? 'Upload image' : 'Pick a profile picture',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
            ),
            addVerticalSpacing(20),
            Center(
              child: GestureDetector(
                // onTap: _openImagePicker,
                onTap: () {
                  selectAndCropImage(context).then((value) async {
                    _image = File('$value');
                    setState(() {});
                  });
                },
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    color: VmodelColors.appBarShadowColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _image != null
                      ? CircleAvatar(
                          radius: 110,
                          backgroundImage: FileImage(
                            _image!,
                            // fit: BoxFit.cover,
                            //       scale: 100
                            // height: SizeConfig.screenWidth * 0.49,
                          ),
                        )
                      : SvgPicture.asset(
                          "assets/icons/upload_image.svg",
                          height: 40,
                          width: 40,
                          // fit: BoxFit.scaleDown,
                        ),
                ),
              ),
            ),
            addVerticalSpacing(32),
            ValueListenableBuilder(
              valueListenable: isShowButtonLoading,
              builder: ((context, value, child) {
                return VWidgetsPrimaryButton(
                  showLoadingIndicator: value,
                  butttonWidth: MediaQuery.sizeOf(context).width,
                  onPressed: () async {
                    VMHapticsFeedback.lightImpact();
                    // final bytes = await _image!.readAsBytes();
                    // String base64Image = base64Encode(bytes);
                    // VLoader.changeLoadingState(true);
                    isShowButtonLoading.value = true;

                    if (_image != null && _image != "") {
                      await ref.read(appUserProvider.notifier).uploadProfilePicture(_image!.path, onProgress: (sent, total) {
                        final percentUploaded = (sent / total);
                      });
                    }

                    // final authNotifier = ref.read(authProvider.notifier);
                    // userIDPk = authNotifier.state.pk!;
                    // final storePk =
                    //     VModelSharedPrefStorage().putInt('pk', userIDPk);
                    // final storeToken = VModelSharedPrefStorage()
                    //     .putString('token', authNotifier.state.token);
                    // await VCredentials.inst.storeUserCredentials(
                    //     authNotifier.state.token);

                    //
                    // Future.wait([storeToken, storePk]);
                    // await authNotifier.pictureUpdate(
                    //     authNotifier.state.pk!, base64Image, '${authNotifier.state.username}_$_imageFilename');
                    // VLoader.changeLoadingState(false);
                    isShowButtonLoading.value = false;
                    if (!mounted) return;
                    ref.invalidate(appUserProvider);
                    context.push('/onboarding-profile-ring');
                  },
                  enableButton: _image != null ? true : false,
                  buttonTitle: 'Next',
                );
              }),
            ),
            addVerticalSpacing(20),
            // Center(
            //   child: TextButton(
            //     onPressed: () {
            //       // go to homepage
            //       // context.go('/feedMainUI');
            //       context.push('/onboarding-profile-ring');
            //     },
            //     child: const Text(
            //       "Skip, add profile later",
            //       style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.w800,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

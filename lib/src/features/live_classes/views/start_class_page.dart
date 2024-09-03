import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../core/utils/enum/upload_ratio_enum.dart';
import '../../../res/icons.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/picture_styles/rounded_square_avatar.dart';
import '../../../shared/rend_paint/render_svg.dart';

const mockData = [
  'assets/images/models/model_2.png',
  'assets/images/models/model_4.png',
  'assets/images/models/model_5.png',
  'assets/images/models/model_6.png',
  'assets/images/models/model_4.png',
  'assets/images/models/model_1.png',
  'assets/images/models/model_2.png',
  'assets/images/models/model_5.png',
];

class StartLiveClassPage extends ConsumerStatefulWidget {
  static const routeName = 'startLiveClassPage';

  const StartLiveClassPage({
    Key? key,
    this.onItemTap,
  }) : super(key: key);
  final ValueChanged? onItemTap;

  @override
  ConsumerState<StartLiveClassPage> createState() => _StartLiveClassPageState();
}

class _StartLiveClassPageState extends ConsumerState<StartLiveClassPage> {
  // @override
  // initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        // backgroundColor: Colors.white,
        appbarTitle: 'Live Classes',
        trailingIcon: [
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: IconButton(
                    padding: const EdgeInsets.only(right: 8),
                    onPressed: () {},
                    icon: const RenderSvg(
                      svgPath: VIcons.searchIcon,
                      svgHeight: 24,
                      svgWidth: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            addVerticalSpacing(16),
            // Row(
            //   children: [
            //     Text(
            //       'Learn how to paint nails with me',
            //       style: context.textTheme.displayMedium?.copyWith(
            //         // fontSize: 13.sp,
            //         fontWeight: FontWeight.w600,
            //       ),
            //       maxLines: 2,
            //       overflow: TextOverflow.ellipsis,
            //     ),
            //   ],
            // ),
            addVerticalSpacing(16),
            Stack(
              children: [
                RoundedSquareAvatar(
                  url: VConstants.testImage,
                  thumbnail: '',
                  // size: UploadAspectRatio.portrait.sizeFromY(15.h),
                  size: Size(90.w, UploadAspectRatio.pro.yDimensionFromX(90.w)),
                ),
                Positioned.fill(
                  child: IconButton(
                      iconSize: 160,
                      color: Colors.white.withOpacity(0.7),
                      icon: Icon(
                        Icons.play_arrow,
                      ),
                      onPressed: () {}),
                ),
              ],
            ),
            addVerticalSpacing(16),
            VWidgetsPrimaryButton(
              // butttonWidth: 30.w,
              onPressed: () {
                // navigateToRoute(context, LiveClassPaymentErrorPage());
                // navigateToRoute(context, LiveClassPaymentSuccessPage());
                context.push('/upcoming_classes');
                // navigateToRoute(context, UpcomingClassesPage());

                //navigateToRoute(context, UpcomingClassesPage());
              },
              enableButton: true,
              buttonTitle: "Continue to class",
            ),
            addVerticalSpacing(16),
          ],
        ),
      ),
    );
  }

  void _navigateToUserProfile(String username) {
    final isCurrentUser =
        ref.read(appUserProvider.notifier).isCurrentUser(username);
    // if (isCurrentUser) {
    //   if (isViewAll) goBack(context);
    //   ref.read(dashTabProvider.notifier).changeIndexState(3);
    // } else {
    /*navigateToRoute(
      context,
      OtherProfileRouter(username: username),
    );*/

    String? _userName = username;
    context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
    // }
  }

  Widget _attributeValueRow(BuildContext context,
      {required String field, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field,
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                // fontWeight: FontWeight.w500,
                height: 1.7,
                color: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.color
                    ?.withOpacity(0.5),
                fontSize: 11.sp,
              ),
        ),
        addHorizontalSpacing(32),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  // fontWeight: FontWeight.w500,
                  height: 1.7,
                  // color: VmodelColors.primaryColor,
                  color: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.color
                      ?.withOpacity(0.5),
                  fontSize: 11.sp,
                ),
          ),
        ),
      ],
    );
  }
}

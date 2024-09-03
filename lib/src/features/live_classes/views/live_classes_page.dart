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
import '../widgets/user_picture_title_subtitle_tile.dart';

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

class LiveClassesPage extends ConsumerStatefulWidget {
  static const routeName = 'liveClassesPage';

  const LiveClassesPage({
    Key? key,
    this.onItemTap,
  }) : super(key: key);
  final ValueChanged? onItemTap;

  @override
  ConsumerState<LiveClassesPage> createState() => _LiveClassesPageState();
}

class _LiveClassesPageState extends ConsumerState<LiveClassesPage> {
  ///
  int limit = 8;
  // int nextItems = 16;
  final controller = ScrollController();
  bool hasMore = true;
  final attributes = [
    'Class date',
    'Class duration',
    'Class fee',
    'Class category',
    'Class level',
  ];
  final values = [
    '04-04-2024',
    '0:30Hr',
    '${VMString.poundSymbol} 2.50',
    'Health and beauty',
    'Masterclass',
  ];

  @override
  initState() {
    super.initState();

    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        setState(() {
          limit *= 2;
        });
      }
    });
  }

  Future fetch() async {}

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.displaySmall;
    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        // leadingWidth: 110,
        leadingIcon: Row(
          children: [
            const VWidgetsBackButton(),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     RenderSvgWithoutColor(
            //       svgPath: VIcons.clock,
            //       svgWidth: 10,
            //       svgHeight: 10,
            //     ),
            //     addHorizontalSpacing(2),
            //     Text(
            //       '7 days',
            //       style: context.textTheme.displaySmall?.copyWith(
            //           fontSize: 10.sp,
            //           color: context.textTheme.displaySmall?.color
            //               ?.withOpacity(0.5),
            //           fontWeight: FontWeight.w400),
            //     ),
            //   ],
            // ),
          ],
        ),
        // backgroundColor: Colors.white,
        appbarTitle: 'Live Classes',
        trailingIcon: [
          // SizedBox(
          //   width: 80,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       Flexible(
          //         child: IconButton(
          //           padding: const EdgeInsets.only(right: 8),
          //           onPressed: () {},
          //           icon: const RenderSvg(
          //             svgPath: VIcons.searchIcon,
          //             svgHeight: 24,
          //             svgWidth: 24,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            ContentUserLocation(
              topText: 'Janet Conner',
              bottomWidget: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: Colors.red,
                  ),
                  Text(
                    'Yorkshire, UK',
                    style: textTheme?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textTheme.color?.withOpacity(0.5),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpacing(16),
            Row(
              children: [
                Text(
                  'Learn how to paint nails with me',
                  style: context.textTheme.displayMedium?.copyWith(
                    // fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            addVerticalSpacing(16),
            ...List.generate(attributes.length, (index) {
              return _attributeValueRow(context,
                  field: attributes[index], value: values[index]);
            }),
            addVerticalSpacing(16),
            Row(
              children: [
                Text(
                  'Description',
                  style: textTheme?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textTheme.color?.withOpacity(0.5),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            addVerticalSpacing(8),
            Text(
              'I will teach you how I do my nails myself, all you need is the nails paint dry tool for amazon and you’re qualified for my class! See you there!',
              style: textTheme?.copyWith(
                fontWeight: FontWeight.w500,
                color: textTheme.color?.withOpacity(0.5),
                fontSize: 11.sp,
              ),
            ),
            addVerticalSpacing(16),
            Stack(
              children: [
                RoundedSquareAvatar(
                  url: VConstants.testImage,
                  thumbnail: '',
                  // size: UploadAspectRatio.portrait.sizeFromY(15.h),
                  size: Size(
                      90.w, UploadAspectRatio.portrait.yDimensionFromX(86.w)),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RenderSvg(
                        svgPath: VIcons.star,
                        svgHeight: 20,
                        svgWidth: 20,
                        color:VmodelColors.starColor,
                      ),
                      addHorizontalSpacing(4),
                      Text('5.0')
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        Icons.favorite,
                      ),
                      onPressed: () {}),
                ),
              ],
            ),
            addVerticalSpacing(16),
            VWidgetsPrimaryButton(
              // butttonWidth: 30.w,

              onPressed: () {
                // context.push('/live_class_checkout_page');
                //navigateToRoute(context, LiveClassCheckoutPage());
                // navigateToRoute(context, CheckOutInfo());
              },
              enableButton: true,
              buttonTitle: "Book Class",
            ),
            addVerticalSpacing(32),
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
    final textTheme = Theme.of(context).textTheme.displayMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field,
          style: textTheme?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.7,
            color: textTheme.color?.withOpacity(0.5),
            fontSize: 11.sp,
          ),
        ),
        addHorizontalSpacing(32),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.7,
              // color: VmodelColors.primaryColor,
              color: textTheme.color?.withOpacity(0.5),
              fontSize: 11.sp,
            ),
          ),
        ),
      ],
    );
  }
}

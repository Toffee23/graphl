import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/DateTime.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/res/ui_constants.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_normal.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../../../shared/job_service_section_container.dart';
import '../model/live_class_type.dart';
import '../widgets/user_picture_title_subtitle_tile.dart';

class LiveClassCheckoutPage extends ConsumerStatefulWidget {
  static const routeName = 'liveClassCheckoutPage';

  const LiveClassCheckoutPage({
    Key? key,
    required this.liveClass,
    this.onItemTap,
  }) : super(key: key);
  final ValueChanged? onItemTap;
  final LiveClassesInput liveClass;

  @override
  ConsumerState<LiveClassCheckoutPage> createState() =>
      _LiveClassCheckoutState();
}

class _LiveClassCheckoutState extends ConsumerState<LiveClassCheckoutPage> {

  @override
  Widget build(BuildContext context) {
    final textColorWithOpacity =
        Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    final baseTextStyle = Theme.of(context).textTheme.displayMedium;

    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: 'Checkout',
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionContainer(
              topRadius: 16,
              bottomRadius: 16,
              height: 47.h,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              color: Theme.of(context).cardTheme.color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  addVerticalSpacing(16),
                  ContentUserLocation(
                    profilePicture:widget.liveClass.ownersProfilePicture,
                    displayName:  widget.liveClass.ownersUsername,
                    topText: widget.liveClass.title,
                    bottomWidget: Text(
                      widget.liveClass.category?.first??'',
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: baseTextStyle?.color?.withOpacity(0.5),
                            fontSize: 11.sp,
                          ),
                    ),
                  ),
                  Divider(),
                  Text('Date and time'),
                  addVerticalSpacing(8),
                  Row(
                    children: [
                      Text(formatTime(widget.liveClass.startTime),
                        style: baseTextStyle?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      addHorizontalSpacing(4),
                      Text("GMT +1:00",
                        style: baseTextStyle?.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: VmodelColors.boldGreyText),
                      ),
                    ],
                  ),
                  // Text('Monday, August 30 at 10:00 GMT +1:00'),
                  addVerticalSpacing(16),
                  Divider(),
                  _attributeValueRow(context,
                      field: 'Class fee', value: 'Price per ticket'),
                  addVerticalSpacing(8),
                  _attributeValueRow(
                    context,
                    field: 'Subtotal',
                    value: VConstants.twoDigitsCurrencyFormatterGB.format(widget.liveClass.price),
                  ),
                  addVerticalSpacing(16),
                  LiveClassPromoField(
                      baseTextStyle: baseTextStyle,
                      textColorWithOpacity: textColorWithOpacity),
                  addVerticalSpacing(16),
                  Center(
                    child: Text(
                      'Promo code applied',
                      style: baseTextStyle?.copyWith(
                        color: textColorWithOpacity,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  Divider(),
                  addVerticalSpacing(16),
                  _attributeValueRow(
                    context,
                    field: 'Total',
                    value: VConstants.twoDigitsCurrencyFormatterGB.format(widget.liveClass.price),
                    fieldTextStyle: baseTextStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      // height: 1.7,
                      fontSize: 11.sp,
                    ),
                    valueTextStyle: baseTextStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      // height: 1.7,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            addVerticalSpacing(20),
            VWidgetsDropdownNormal<String>(
              fieldLabel: 'Payment method',
              fieldLabelStyle: baseTextStyle?.copyWith(
                  fontWeight: FontWeight.bold, height: 1.7, fontSize: 11.sp),
              validator: null,
              hintText: 'Account Type',
              items: ['Personal ****3456', 'Business ****6789'],
              isExpanded: true,
              // fieldLabel: "Select Gig or Service",
              onChanged: (value) {},
              value: 'Personal ****3456',
              itemToString: (value) => value,
              customDecoration: _dropDownDecoration(context),
            ),
            addVerticalSpacing(16),
            VWidgetsPrimaryButton(
              onPressed: () {
                context.push('/live_class_card_input_page',extra: widget.liveClass);
              },
              enableButton: true,
              buttonTitle: "Pay with Apple Pay",
            ),
            VWidgetsPrimaryButton(
              onPressed: () {
                context.push('/live_class_card_input_page',extra: widget.liveClass);
              },
              enableButton: true,
              buttonTitle: "Pay with PayPal",
            ),
            VWidgetsPrimaryButton(
              onPressed: () {
                context.push('/live_class_card_input_page',extra: widget.liveClass);
              },
              enableButton: true,
              buttonTitle: "Pay with Credit Card",
            ),
            addVerticalSpacing(32),
          ],
        ),
      ),
    );
  }

  Widget _attributeValueRow(BuildContext context,
      {required String field,
      required String value,
      TextStyle? fieldTextStyle,
      TextStyle? valueTextStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field,
          style: fieldTextStyle ??
              Theme.of(context).textTheme.displayMedium!.copyWith(
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
            style: valueTextStyle ??
                Theme.of(context).textTheme.displayMedium!.copyWith(
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

  InputDecoration _dropDownDecoration(BuildContext context) {
    final textColorWithOpacity =
        Theme.of(context).textTheme.displayMedium?.color?.withOpacity(0.5);
    final baseTextStyle = Theme.of(context).textTheme.displayMedium;
    return UIConstants.instance
        .inputDecoration(
          context,
          hintText: '',
          hintStyle: baseTextStyle?.copyWith(
              fontSize: 11.sp, color: textColorWithOpacity),
          // isCollapsed: true,
          contentPadding: const EdgeInsets.fromLTRB(48, 0, 10, 8),
        )
        .copyWith(
          isDense: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(VIcons.masterCardLogo),
          ),
          prefixIconConstraints: BoxConstraints(maxHeight: 32, maxWidth: 32),
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //       color: Theme.of(context).buttonTheme.colorScheme!.primary,
          //       width: 1),
          //   borderRadius: const BorderRadius.all(Radius.circular(6)),
          // ),
        );
  }
}

class LiveClassPromoField extends StatelessWidget {
  const LiveClassPromoField({
    super.key,
    required this.baseTextStyle,
    required this.textColorWithOpacity,
  });

  final TextStyle? baseTextStyle;
  final Color? textColorWithOpacity;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // controller: controller,
      maxLines: 1,
      // validator: (val) {
      // if (val?.toLowerCase() == 'car') {
      //   //print('Errorxx');
      //   return 'Worn';
      // }
      // return null;
      // },
      style: baseTextStyle?.copyWith(
        fontWeight: FontWeight.w400,
        color: Theme.of(context).primaryColor,
      ),
      decoration: UIConstants.instance
          .inputDecoration(
            context,
            hintText: 'Promo Code',
            hintStyle: baseTextStyle?.copyWith(
                fontSize: 11.sp, color: textColorWithOpacity),
            // isCollapsed: true,
            suffixWidget: InkResponse(
              borderRadius: BorderRadius.circular(8),
              // containedInkWell: true,
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4),
                color: Colors.transparent,
                child: Text(
                  'Apply',
                  style: baseTextStyle?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(48, 0, 10, 8),
          )
          .copyWith(
            isDense: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  RenderSvgWithoutColor(svgPath: VIcons.ticketDiscountFilled),
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 32, maxWidth: 32),
            enabledBorder: OutlineInputBorder(
              borderSide: Theme.of(context)
                  .inputDecorationTheme
                  .focusedBorder!
                  .borderSide
                  .copyWith(
                    width: 1,
                  ),
              // borderSide: BorderSide(
              //     color: Theme.of(context).buttonTheme.colorScheme!.primary,
              //     width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
          ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/enum/album_type.dart';
import '../controller/gallery_controller.dart';

class VWidgetsProfileButtons extends ConsumerStatefulWidget {
  final VoidCallback? bookingsOnPressed;
  final VoidCallback? polaroidOnPressed;
  final VoidCallback? portfolioOnPressed;
  final VoidCallback? messagesOnPressed;
  final VoidCallback? socialAccountsOnPressed;
  final VoidCallback? socialAccountsOnLongPress;
  final VoidCallback? servicesOnPressed;
  final VoidCallback? networkOnPressed;
  final bool connected;

  const VWidgetsProfileButtons({
    super.key,
    required this.bookingsOnPressed,
    required this.polaroidOnPressed,
    required this.portfolioOnPressed,
    required this.messagesOnPressed,
    required this.socialAccountsOnPressed,
    required this.socialAccountsOnLongPress,
    required this.servicesOnPressed,
    required this.networkOnPressed,
    this.connected = false,
  });

  @override
  ConsumerState<VWidgetsProfileButtons> createState() => _VWidgetsProfileButtonsState();
}

class _VWidgetsProfileButtonsState extends ConsumerState<VWidgetsProfileButtons> {
  @override
  Widget build(BuildContext context) {
    // bool showPolaroid = ref.watch(showPolaroidProvider);
    final showPolaroid = ref.watch(galleryTypeFilterProvider(null));
    return Wrap(
      runSpacing: 5,
      verticalDirection: VerticalDirection.down,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: VWidgetsPrimaryButton(
                buttonHeight: 40,
                elevation: 0,
                onPressed: widget.bookingsOnPressed,
                buttonTitle: "My bookings",
                enableButton: true,
                buttonColor: Theme.of(context).buttonTheme.colorScheme?.background,
              ),
            ),
            addHorizontalSpacing(8),
            Expanded(
              child: VWidgetsPrimaryButton(
                buttonHeight: 40,
                onPressed: widget.networkOnPressed,
                buttonTitle: "My network",
                                elevation: 0,

                enableButton: true,
                buttonColor: Theme.of(context).buttonTheme.colorScheme?.background,
              ),
            ),
          ],
        ),
        // addVerticalSpacing(5),
        Row(
          children: [
            // if (showPolaroid == true)
            if (showPolaroid == AlbumType.polaroid)
              Flexible(
                child: VWidgetsPrimaryButton(
                  buttonHeight: 40,
                  onPressed: widget.portfolioOnPressed,
                  buttonTitle: "Portfolio",
                                  elevation: 0,

                  enableButton: true,
                  // buttonColor: VmodelColors.buttonBgColor,
                  buttonColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
                  buttonTitleTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            // if (showPolaroid == false)
            if (showPolaroid == AlbumType.portfolio)
              Flexible(
                child: VWidgetsPrimaryButton(
                  buttonHeight: 40,
                  onPressed: () {
                    context.push('/myRequestPage');
                  }, //widget.servicesOnPressed, //widget.polaroidOnPressed,
                  buttonTitle: "My requests",
                                  elevation: 0,

                  enableButton: true,
                  buttonColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
                  buttonTitleTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        // color: Theme.of(context).buttonTheme.colorScheme?.secondary,
                      ),
                ),
              ),
            addHorizontalSpacing(6),
            Flexible(
              child: VWidgetsPrimaryButton(
                buttonHeight: 40,
                onPressed: widget.messagesOnPressed,
                buttonTitle: "Messages",
                                elevation: 0,

                enableButton: widget.connected,
                buttonColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
                buttonTitleTextStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      // color: Theme.of(context).primaryColor,
                    ),
              ),
            ),
            addHorizontalSpacing(6),
            SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                                  elevation: 0,

                    backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
                    // foregroundColor:
                    //     Theme.of(context).buttonTheme.colorScheme?.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero),
                onLongPress: widget.socialAccountsOnLongPress,
                onPressed: widget.socialAccountsOnPressed,
                child: RenderSvg(
                  svgHeight: 24,
                  // svgPath: VIcons.cameraCaptureIcon,
                  svgPath: VIcons.instaFilled,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).buttonTheme.colorScheme?.onSecondary.withOpacity(0.7)
                      : Theme.of(context).buttonTheme.colorScheme?.onSecondary,
                ),
              ),
            ),
            // addHorizontalSpacing(6),
            // SizedBox(
            //   width: 40,
            //   height: 40,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //
            //         backgroundColor: Theme.of(context).buttonTheme.colorScheme?.secondary,
            //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            //         padding: EdgeInsets.zero),
            //     onPressed: widget.servicesOnPressed,
            //     child: RenderSvg(
            //       svgPath: VIcons.shopIcon,
            //       color: Theme.of(context).brightness == Brightness.dark
            //           ? Theme.of(context).buttonTheme.colorScheme?.onSecondary.withOpacity(0.7)
            //           : Theme.of(context).buttonTheme.colorScheme?.onSecondary,
            //     ),
            //   ),
            // ),
          ],
        ),
        // addVerticalSpacing(10),
      ],
    );
  }
}

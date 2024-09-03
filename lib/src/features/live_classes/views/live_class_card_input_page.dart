import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/buttons/primary_button.dart';
import '../../settings/views/verification/views/blue-tick/widgets/text_field.dart';
import '../model/live_class_type.dart';

class LiveClassCardInputPage extends ConsumerStatefulWidget {
  static const routeName = 'liveClassCheckoutPage';

  const LiveClassCardInputPage({
    this.onItemTap,
    required this.liveClass,
  });
  final ValueChanged? onItemTap;
  final LiveClassesInput liveClass;

  @override
  ConsumerState<LiveClassCardInputPage> createState() =>
      _LiveClassCardInputPageState();
}

class _LiveClassCardInputPageState
    extends ConsumerState<LiveClassCardInputPage> {
  @override
  initState() {
    super.initState();
  }

  Future fetch() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: 'Checkout',
      ),
      body: SingleChildScrollView(
        // physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VWidgetsTextFieldNormal(
              labelText: "Card Number",
              hintText: "Ex. 1234 45678 1234 5678",
              // controller: locController,
              onChanged: (value) {},
            ),
            addVerticalSpacing(16),
            VWidgetsTextFieldNormal(
              labelText: "Card holder name",
              hintText: "Ex. Jane Conner",
              // controller: locController,
              onChanged: (value) {},
            ),
            addVerticalSpacing(16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: VWidgetsTextFieldNormal(
                    labelText: "Expiration date",
                    hintText: "MM/YY",
                    // controller: locController,
                    onChanged: (value) {},
                  ),
                ),
                addHorizontalSpacing(16),
                Flexible(
                  child: VWidgetsTextFieldNormal(
                    labelText: "Security Code",
                    hintText: "CVC",
                    // controller: locController,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            addVerticalSpacing(32),
            VWidgetsPrimaryButton(
              onPressed: () {
                context.push('/live_class_payment_success_page', extra: widget.liveClass);
              },
              enableButton: true,
              buttonTitle: "Confirm payment ${VMString.bullet} ${VConstants.twoDigitsCurrencyFormatterGB.format(2.50)}",
            ),
            VWidgetsTextButton(
              onPressed: () {
                context.push('/live_class_payment_failed_page');
              },
              text: 'Payment failed',
            ),
            addVerticalSpacing(20)
          ],
        ),
      ),
    );
  }
}

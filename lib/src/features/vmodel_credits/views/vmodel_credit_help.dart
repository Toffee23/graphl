import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../shared/appbar/appbar.dart';
import '../../settings/widgets/settings_submenu_tile_widget.dart';
import '../../tutorials/models/tutorial_mock.dart';

class UserVModelCreditHelp extends ConsumerStatefulWidget {
  const UserVModelCreditHelp({super.key});
  static const routeName = 'vmc';

  @override
  ConsumerState<UserVModelCreditHelp> createState() =>
      _UserVModelCreditHelpState();
}

class _UserVModelCreditHelpState extends ConsumerState<UserVModelCreditHelp> {
  final referCodeCopied = ValueNotifier<bool>(false);
  final referCode = 1050;
  final pageIndex = ValueNotifier<int>(0);
  late final faqs;

  @override
  void initState() {
    super.initState();

    faqs = HelpSupportModel.vmodelCredits();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(appUserProvider);
    final user = userState.valueOrNull;
    final vmc = ref.watch(vmcRecordProvider);
    return ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (context, value, child) {
          return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: VWidgetsAppBar(
                leadingIcon: const VWidgetsBackButton(),
                appbarTitle: 'VModel Credits Help',
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    physics: const BouncingScrollPhysics(),
                    itemCount: faqs.length,
                    shrinkWrap: true,
                    itemBuilder: ((context, index) {
                      // return popularFAQs[index];

                      return VWidgetsSettingsSubMenuTileWidget(
                          title: faqs[index].title!,
                          onTap: () {
                            var ss = faqs[index];
                            // navigateToRoute(
                            //     context,
                            //     HelpDetailsViewTwo(
                            //       tutorialDetailsTitle: ss.title,
                            //       tutorialDetailsDescription: ss.body,
                            //     ));
                          });
                    }),
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ));
        });
  }
}

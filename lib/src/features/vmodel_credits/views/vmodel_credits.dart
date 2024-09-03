import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/features/beta_dashboard/views/beta_dashboard_browser.dart';
import 'package:vmodel/src/features/vmodel_credits/controller/vmc_controller.dart';
import 'package:vmodel/src/features/vmodel_credits/models/achievements_list.dart';
import 'package:vmodel/src/features/vmodel_credits/widgets/achievement_item.dart';
import 'package:vmodel/src/res/gap.dart';
import 'package:vmodel/src/shared/response_widgets/error_dialogue.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/app_user_controller.dart';
import '../../../shared/appbar/appbar.dart';
import '../../tutorials/models/tutorial_mock.dart';
import '../widgets/counter_animation.dart';

class UserVModelCreditHomepage extends ConsumerStatefulWidget {
  const UserVModelCreditHomepage({super.key});
  static const routeName = 'vmc';

  @override
  ConsumerState<UserVModelCreditHomepage> createState() => _UserVModelCreditHomepageState();
}

class _UserVModelCreditHomepageState extends ConsumerState<UserVModelCreditHomepage> {
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
          // if (value == 0) {
          //   return VModelCreditsOnboarding(pageIndex: pageIndex);
          // }

          return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: VWidgetsAppBar(
                leadingIcon: const VWidgetsBackButton(),
                appbarTitle: 'Achievements',
              ),
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(15),
                      GestureDetector(
                        onTap: vmc.value != null ? () => context.push('/CreditHistoryPage/false') : null,
                        child: ValueListenableBuilder(
                            valueListenable: referCodeCopied,
                            builder: (context, value, child) {
                              return Container(
                                // color: Colors.red,
                                height: 200,
                                alignment: Alignment.center,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.30), offset: Offset(0, 3), blurRadius: 16)],
                                    gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Color(0xffA422E2), Color(0xffFD762F)])),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          'VModel Credits',
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                                              ),
                                        ),
                                      ),
                                    ),
                                    addVerticalSpacing(35),
                                    Center(
                                      child: vmc.when(
                                        data: (data) {
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CounterAnimationText(
                                                begin: 0,
                                                end: ref.watch(vmcTotalProvider),
                                                durationInMilliseconds: 700,
                                                curve: Curves.fastEaseInToSlowEaseOut,
                                                textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                                      height: 1,
                                                      fontSize: 50,
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                                                    ),
                                              ),
                                              // Text(
                                              //   '$referCode',
                                              //   style: Theme.of(context)
                                              //       .textTheme
                                              //       .headlineLarge!
                                              //       .copyWith(
                                              //         fontWeight: FontWeight.bold,
                                              //       ),
                                              // ),
                                              addHorizontalSpacing(5),
                                              Text(
                                                'VMC',
                                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                      height: 1,
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                      color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                                                    ),
                                              ),
                                            ],
                                          );
                                        },
                                        error: (error, stacktrace) {
                                          return Center(
                                            child: Text(error.toString()),
                                          );
                                        },
                                        loading: () => CircularProgressIndicator(),
                                      ),
                                    ),
                                    Spacer(),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: InkWell(
                                        onTap: () {
                                          // navigateToRoute(
                                          //     context, UserVModelCreditHelp());
                                          // context.push('/user_credit_help');
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (builder) => BetaDashBoardWeb(title: "VMC", url: 'https://www.vmodelapp.com/help-center?section=vmodel_credits/how_to_earn_vmc')));
                                        },
                                        child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.black38,
                                            child: Icon(
                                              Icons.question_mark,
                                              color: Colors.white,
                                              size: 20,
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                      addVerticalSpacing(15),
                      ref.watch(achievementProvider(null)).when(
                          data: (data) {
                            final unearnedBadge = [...achievementList];
                            for (var e in data) {
                              unearnedBadge.removeWhere(
                                (element) => element['title'].toString().replaceAll("\n", " ").toLowerCase() == e.achievement.title.toLowerCase(),
                              );
                            }
                            return Center(
                              child: Wrap(
                                spacing: 10.w,
                                runSpacing: 20,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  ...data.map((e) => AchievementItemWidget(data: e)),
                                  ...unearnedBadge.map((e) => AchievementItemWidget(badgeTitle: e['title'])),
                                ],
                              ),
                            );
                          },
                          error: (e, _) => CustomErrorDialogWithScaffold(
                                onTryAgain: () {
                                  ref.invalidate(achievementProvider);
                                },
                                title: "Achievments",
                                showAppbar: false,
                              ),
                          loading: () => Center(child: CircularProgressIndicator.adaptive())),

                      // addVerticalSpacing(25),
                      // GestureDetector(
                      //   onTap: vmc.value != null
                      //       ? () => context.push('/CreditHistoryPage/false')
                      //       : null,
                      //   child: ValueListenableBuilder(
                      //       valueListenable: referCodeCopied,
                      //       builder: (context, value, child) {
                      //         return Container(
                      //           // color: Colors.red,
                      //           height: 200,
                      //           alignment: Alignment.center,
                      //           width: double.infinity,
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(20),
                      //               boxShadow: [
                      //                 BoxShadow(
                      //                     color: Colors.black.withOpacity(0.30),
                      //                     offset: Offset(0, 3),
                      //                     blurRadius: 16)
                      //               ],
                      //               gradient: LinearGradient(
                      //                   begin: Alignment.bottomLeft,
                      //                   end: Alignment.topRight,
                      //                   colors: [
                      //                     Color(0xffA422E2),
                      //                     Color(0xffFD762F)
                      //                   ])),
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 10, vertical: 10),
                      //           child: Column(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             crossAxisAlignment: CrossAxisAlignment.center,
                      //             children: [
                      //               Align(
                      //                 alignment: Alignment.topRight,
                      //                 child: Padding(
                      //                   padding:
                      //                       const EdgeInsets.only(right: 8.0),
                      //                   child: Text(
                      //                     'VModel Credits',
                      //                     style: Theme.of(context)
                      //                         .textTheme
                      //                         .titleMedium!
                      //                         .copyWith(
                      //                           fontSize: 12,
                      //                           fontWeight: FontWeight.w600,
                      //                           color: Theme.of(context)
                      //                               .buttonTheme
                      //                               .colorScheme
                      //                               ?.onPrimary,
                      //                         ),
                      //                   ),
                      //                 ),
                      //               ),
                      //               addVerticalSpacing(35),
                      //               Center(
                      //                 child: vmc.when(
                      //                   data: (data) {
                      //                     return Column(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.center,
                      //                       crossAxisAlignment:
                      //                           CrossAxisAlignment.center,
                      //                       children: [
                      //                         CounterAnimationText(
                      //                           begin: 0,
                      //                           end:
                      //                               ref.watch(vmcTotalProvider),
                      //                           durationInMilliseconds: 700,
                      //                           curve: Curves
                      //                               .fastEaseInToSlowEaseOut,
                      //                           textStyle: Theme.of(context)
                      //                               .textTheme
                      //                               .headlineLarge!
                      //                               .copyWith(
                      //                                 height: 1,
                      //                                 fontSize: 50,
                      //                                 fontWeight:
                      //                                     FontWeight.bold,
                      //                                 color: Theme.of(context)
                      //                                     .buttonTheme
                      //                                     .colorScheme
                      //                                     ?.onPrimary,
                      //                               ),
                      //                         ),
                      //                         // Text(
                      //                         //   '$referCode',
                      //                         //   style: Theme.of(context)
                      //                         //       .textTheme
                      //                         //       .headlineLarge!
                      //                         //       .copyWith(
                      //                         //         fontWeight: FontWeight.bold,
                      //                         //       ),
                      //                         // ),
                      //                         addHorizontalSpacing(5),
                      //                         Text(
                      //                           'VMC',
                      //                           style: Theme.of(context)
                      //                               .textTheme
                      //                               .titleMedium!
                      //                               .copyWith(
                      //                                 height: 1,
                      //                                 fontSize: 20,
                      //                                 fontWeight:
                      //                                     FontWeight.w700,
                      //                                 color: Theme.of(context)
                      //                                     .buttonTheme
                      //                                     .colorScheme
                      //                                     ?.onPrimary,
                      //                               ),
                      //                         ),
                      //                       ],
                      //                     );
                      //                   },
                      //                   error: (error, stacktrace) {
                      //                     return Center(
                      //                       child: Text(error.toString()),
                      //                     );
                      //                   },
                      //                   loading: () => CircularProgressIndicator(),
                      //                 ),
                      //               ),
                      //               Spacer(),
                      //               Align(
                      //                 alignment: Alignment.bottomRight,
                      //                 child: InkWell(
                      //                   onTap: () {
                      //                     // navigateToRoute(
                      //                     //     context, UserVModelCreditHelp());
                      //                     context.push('/user_credit_help');
                      //                   },
                      //                   child: CircleAvatar(
                      //                       radius: 18,
                      //                       backgroundColor: Colors.black38,
                      //                       child: Icon(
                      //                         Icons.question_mark,
                      //                         color: Colors.white,
                      //                         size: 20,
                      //                       )),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         );
                      //       }),
                      // ),
                      // addVerticalSpacing(16),
                      // Expanded(
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 25.0),
                      //     child: Container(
                      //       margin: const EdgeInsets.only(
                      //         left: 18,
                      //         right: 18,
                      //       ),
                      //       child: ListView.separated(
                      //         physics: const BouncingScrollPhysics(),
                      //         itemCount: faqs.length,
                      //         shrinkWrap: true,
                      //         itemBuilder: ((context, index) {
                      //           // return popularFAQs[index];
                      //
                      //           return VWidgetsSettingsSubMenuTileWidget(
                      //               title: faqs[index].title!,
                      //               onTap: () {
                      //                 var ss = faqs[index];
                      //                 // navigateToRoute(
                      //                 //     context,
                      //                 //     HelpDetailsViewTwo(
                      //                 //       tutorialDetailsTitle: ss.title,
                      //                 //       tutorialDetailsDescription: ss.body,
                      //                 //     ));
                      //               });
                      //         }),
                      //         separatorBuilder: (context, index) =>
                      //             const Divider(),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      addVerticalSpacing(35),
                    ],
                  ),
                ),
              ));
        });
  }
}

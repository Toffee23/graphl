import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:go_router/go_router.dart';

class ContentNote extends ConsumerStatefulWidget {
  const ContentNote({Key? key, required this.name, required this.rating, required this.description, required this.onUsernameTap}) : super(key: key);

  final String name;
  final String rating;
  final String description;
  final VoidCallback onUsernameTap;

  @override
  ConsumerState<ContentNote> createState() => _ContentNoteState();
}

class _ContentNoteState extends ConsumerState<ContentNote> {
  bool readMore = true;
  void showMore() {
    setState(() {
      readMore = !readMore;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    final currentUser = ref.watch(appUserProvider).valueOrNull;
    return Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
                onTap: () {
                  ref.read(dashTabProvider.notifier).changeIndexState(3);
                  final appUser = ref.watch(appUserProvider);
                  final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

                  if (isBusinessAccount) {
                    context.push('/localBusinessProfileBaseScreen/${widget.name}');
                  } else {
                    context.push('/profileBaseScreen');
                  }
                  final posterUsername = widget.name;
                  if (posterUsername == '${currentUser?.username}') {
                    final appUser = ref.watch(appUserProvider);
                    final isBusinessAccount = appUser.valueOrNull?.isBusinessAccount ?? false;

                    if (isBusinessAccount) {
                      context.push('/localBusinessProfileBaseScreen/$posterUsername');
                    } else {
                      context.push('/profileBaseScreen');
                    }

                    // return LocalBusinessProfileBaseScreen(
                    //     username: appUser.valueOrNull!.username, isCurrentUser: true);
                    // return const ProfileBaseScreen(isCurrentUser: true);
                  } else {
                    String? _userName = posterUsername;
                    context.push('${Routes.otherProfileRouter.split("/:").first}/$_userName');
                  }
                },
                child: Row(
                  children: [
                    Text(
                      widget.name,
                      style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SvgPicture.asset(VIcons.verifiedIcon),
                    const SizedBox(
                      width: 10,
                    ),
                    SvgPicture.asset(VIcons.userIcon),
                    const SizedBox(
                      width: 2,
                    ),
                    Text(
                      widget.rating,
                      style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                )),
            const SizedBox(
              height: 10,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "${widget.description}",
                style: textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white),
              ),
              // TextSpan(
              //     text: 'Elena Michaels. ',
              //     style: textTheme.displayMedium!.copyWith(
              //         fontWeight: FontWeight.w400,
              //         fontSize: 14,
              //         color: VmodelColors.text2.withOpacity(0.8))),
              // TextSpan(
              //   text: " It was an amazing experience . Here’s the ",
              //   style: textTheme.displayMedium!.copyWith(
              //       fontWeight: FontWeight.w400,
              //       fontSize: 14,
              //       color: Colors.white.withOpacity(0.8)),
              // ),
              // if (readMore == true)
              //   TextSpan(
              //       text: "results if the shoot. Download",
              //       style: textTheme.displayMedium!.copyWith(
              //           fontWeight: FontWeight.w400,
              //           fontSize: 14,
              //           color: Colors.white.withOpacity(0.8))),
              TextSpan(
                text: readMore == false ? " ..Show more" : " ..Show less",
                recognizer: TapGestureRecognizer()..onTap = () => showMore(),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(color: VmodelColors.text2, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ])),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 6),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       SvgPicture.asset(VIcons.waveIcon),
            //       const SizedBox(
            //         width: 8,
            //       ),
            //       Text(
            //         'Burnaboy - Location',
            //         style: textTheme.displayMedium!.copyWith(
            //             fontWeight: FontWeight.w400,
            //             fontSize: 14,
            //             color: Colors.white.withOpacity(0.8)),
            //       )
            //     ],
            //   ),
            // )
          ],
        ));
  }
}

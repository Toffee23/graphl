import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/user_prefs_controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/settings/views/account_settings/widgets/account_settings_card.dart';
import 'package:vmodel/src/features/settings/widgets/settings_submenu_tile_widget.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_interaction_textfields.dart';
import 'package:vmodel/src/shared/text_fields/dropdown_text_field.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:go_router/go_router.dart';

class FeedSettingsHomepage extends ConsumerStatefulWidget {
  const FeedSettingsHomepage({super.key});
  @override
  ConsumerState<FeedSettingsHomepage> createState() =>
      _FeedSettingsHomepageState();
}

class _FeedSettingsHomepageState extends ConsumerState<FeedSettingsHomepage> {
  final options0 = ['On', 'Off'];
  final options = ['Normal feed view', 'Recommended Feed'];
  final options1 = ['Normal feed style', 'Slides'];
  String? value0;
  String? value;
  String? value1;
  bool isDefaultSlides = true;

  @override
  initState() {
    super.initState();
    value0 = ref.read(autoPlayNotifier);
    value = ref.read(isRecommendedViewNotifier) ? options.last : options.first;
    isDefaultSlides = true;
  }

  @override
  Widget build(BuildContext context) {
    final userPrefsConfig = ref.watch(userPrefsProvider);
    List feedItems = [
      VWidgetsAccountSettingsCard(
        title: "Content autoplay",
        subtitle: value0,
        onTap: () {
          navigateToRoute(
              context,
              InteractionDropdown<String>(
                title: "Content autoplay",
                value: value0 ?? '',
                dropdownValues: options0,
                itemToString: (value) => value,
                onDone: (val) {
                  setState(() {
                    value0 = val;
                  });
                  ref.read(autoPlayNotifier.notifier).setAutoplaySettings(val);
                },
              ));
        },
      ),

      VWidgetsAccountSettingsCard(
        title: "Default feed view",
        subtitle: value,
        onTap: () {
          navigateToRoute(
              context,
              InteractionDropdown<String>(
                title: "Default feed view",
                value: value ?? '',
                dropdownValues: options,
                itemToString: (value) => value,
                onDone: (val) {
                  setState(() {
                    value = val;
                  });
                },
              ));
        },
      ),

      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Default feed view",
      //     textAlign: TextAlign.start,
      //     onTap: () {
      //       context.push('/DefaultFeedViewDropdownInput');
      //     }),
      // VWidgetsDropDownTextField(
      //   maxLength: 8.h.toInt(),
      //   // fieldLabel: widget.title,
      //   // hintText: widget.value == null ? 'select ...' : '',
      //   hintText: '',
      //   value: value,
      //   // value: isDefaultSlides ? options.last : options.first,
      //   isExpanded: true,
      //   onChanged: (val) {
      //     setState(() {
      //       // dropdownIdentifyValue = val;
      //       value = val;
      //     });

      //     // //print(widget.value);
      //   },
      //   options: options,
      // ),
      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Content",
      //     textAlign: TextAlign.start,
      //     onTap: () {
      //       context.push('/ContentFeedViewDropdownInput');
      //     }),

      userPrefsConfig.maybeWhen(data: (configs) {
        isDefaultSlides = configs.isDefaultFeedViewSlides;

        return VWidgetsAccountSettingsCard(
          title: "Content",
          subtitle: isDefaultSlides ? options1.last : options1.first,
          onTap: () {
            navigateToRoute(
                context,
                InteractionDropdown<String>(
                  title: "Content",
                  value: isDefaultSlides ? options1.last : options1.first,
                  dropdownValues: options1,
                  itemToString: (value) => value,
                  onDone: (val) {
                    isDefaultSlides =
                        val.toLowerCase() == 'Slides'.toLowerCase();

                    ref.read(userPrefsProvider.notifier).addOrUpdatePrefsEntry(
                        userPrefsConfig.value!.copyWith(
                            isDefaultFeedViewSlides: isDefaultSlides));

                    setState(() {
                      // dropdownIdentifyValue = val;
                      // value1 = val;
                    });
                  },
                ));
          },
        );
        // return VWidgetsDropDownTextField(
        //   maxLength: 6.h.toInt(),
        //   // fieldLabel: widget.title,
        //   // hintText: widget.value == null ? 'select ...' : '',
        //   hintText: '',
        //   // value: widget.value,
        //   value: isDefaultSlides ? options1.last : options1.first,
        //   isExpanded: true,
        //   onChanged: (val) {
        //     isDefaultSlides = val.toLowerCase() == 'Slides'.toLowerCase();

        //     ref.read(userPrefsProvider.notifier).addOrUpdatePrefsEntry(
        //         userPrefsConfig.value!
        //             .copyWith(isDefaultFeedViewSlides: isDefaultSlides));

        //     setState(() {
        //       // dropdownIdentifyValue = val;
        //       // value1 = val;
        //     });
        //   },
        //   options: options1,
        // );
      }, orElse: () {
        return Text('Error getting user configs');
      }),

      // VWidgetsSettingsSubMenuTileWidget(
      //     title: "Interests",
      //     onTap: () {
      //       navigateToRoute(context, InterestSelectionDialog());
      //     }),
    ];
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Feed",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: Column(
        children: [
          addVerticalSpacing(25),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                  itemBuilder: ((context, index) => feedItems[index]),
                  separatorBuilder: (context, index) => const SizedBox(),
                  itemCount: feedItems.length),
            ),
          ),
        ],
      ),
    );
  }
}

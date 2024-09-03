import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/enum/ethnicity_enum.dart';
import 'package:vmodel/src/core/utils/enum/gender_enum.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import 'package:vmodel/src/features/authentication/register/provider/user_types_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/widgets/interest_dialog.dart';
import 'package:vmodel/src/features/settings/views/account_settings/widgets/account_settings_card.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/text_fields/ethnicity_fields_dropdown.dart';
import 'package:vmodel/src/shared/text_fields/gender_fields_dropdown.dart';
import 'package:vmodel/src/shared/text_fields/profile_dropdown_input.dart';
import 'package:vmodel/src/shared/text_fields/profile_input_field.dart';
import 'package:vmodel/src/shared/text_fields/traits_fields_dropdown.dart';
import 'package:vmodel/src/vmodel.dart';

class ProfileSettingsHomepage extends ConsumerStatefulWidget {
  const ProfileSettingsHomepage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileSettingsHomepageState();
}

class _ProfileSettingsHomepageState extends ConsumerState<ProfileSettingsHomepage> {
  AsyncValue<AccountType?>? userTypes;
  AccountType? allUserTypes;
  String _selectedSubProfile = "";
  bool _value = false;

  final Gender? dropdownIdentifyValue = Gender.any;
  List<String> subTalentList = [];

  @override
  void initState() {
    _value = ref.read(appUserProvider).valueOrNull!.displayZodiacSign! == 'YES' ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appUserState = ref.watch(appUserProvider);

    final user = appUserState.valueOrNull;
    final userTypes = ref.watch(accountTypesProvider);
    final allUserTypes = userTypes.valueOrNull;

    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Portfolio Settings",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: AssetImage('assets/images/betaDashboardBanner.jpg'), fit: BoxFit.cover),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Profile completion",
                        style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              color: VmodelColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                      ),
                      addVerticalSpacing(4),
                      Text(
                        '${(user?.profilePercentage?.percentage ?? 0)}%',
                        // textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: VmodelColors.white,
                              fontSize: 12.sp,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            addVerticalSpacing(20),
            VWidgetsAccountSettingsCard(
              title: "Display Name",
              subtitle: user!.displayName,
              onTap: () {
                navigateToRoute(
                  context,
                  ProfileInputField(
                    title: "Display Name",
                    value: user.displayName,
                    onSave: (newValue) async {
                      // await Future.delayed(const Duration(seconds: 5));
                      await ref.read(appUserProvider.notifier).updateProfile(displayName: newValue);
                    },
                  ),
                );
              },
            ),
            VWidgetsAccountSettingsCard(
              title: "Username",
              subtitle: user.username.toLowerCase(),
              onTap: () {
                navigateToRoute(
                  context,
                  ProfileInputField(
                    title: "Username",
                    value: user.username.toLowerCase(),
                    onSave: (newValue) async {
                      final save = await ref.read(appUserProvider.notifier).updateUsername(username: newValue);
                      if (!save) {
                        SnackBarService().showSnackBarError(context: context);
                      } else {
                        ref.read(authenticationStatusProvider.notifier).logout(context);
                      }
                    },
                  ),
                );
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Ethnicity",
              subtitle: "${user.ethnicity == null ? "None" : user.ethnicity!.simpleName}",
              onTap: () {
                navigateToRoute(
                    context,
                    EthnicityFieldDropdown(
                      title: "Ethnicity",
                      value: user.ethnicity ?? Ethnicity.values[0],
                      pk: user.id!,
                      dropdownIdentifyValue: dropdownIdentifyValue,
                    ));
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Traits",
              subtitle: "${user.trait == null ? "None" : user.trait!}",
              onTap: () {
                navigateToRoute(
                    context,
                    TraitsFieldDropdown(
                      title: "Traits",
                      value: user.trait ?? VConstants.userTraits[0],
                      pk: user.id!,
                      dropdownIdentifyValue: dropdownIdentifyValue,
                    ));
              },
            ),

            VWidgetsAccountSettingsCard(
              title: "Bio",
              subtitle: user.bio ?? '',
              onTap: () {
                navigateToRoute(
                    context,
                    ProfileInputField(
                      title: "Bio",
                      value: user.bio ?? '',
                      isBio: true,
                      onSave: (newValue) async {
                        await ref.read(appUserProvider.notifier).updateProfile(bio: newValue);
                      },
                    ));
              },
            ),
            // VWidgetsAccountSettingsCard(
            //   title: "Hair Color",
            //   subtitle: user.hair ?? '',
            //   onTap: () {
            //     navigateToRoute(
            //         context,
            //         ProfileInputField(
            //           title: "Hair Color",
            //           value: user.hair ?? '',
            //           onSave: (newValue) async {
            //             await ref
            //                 .read(appUserProvider.notifier)
            //                 .updateProfile(hair: newValue);
            //           },
            //         ));
            //   },
            // ),
            // VWidgetsAccountSettingsCard(
            //   title: "Eye Color",
            //   subtitle: user.eyes ?? '',
            //   onTap: () {
            //     navigateToRoute(
            //         context,
            //         ProfileInputField(
            //           title: "Eye Color",
            //           value: user.eyes ?? '',
            //           onSave: (newValue) async {
            //             await ref
            //                 .read(appUserProvider.notifier)
            //                 .updateProfile(eyes: newValue);
            //           },
            //         ));
            //   },
            // ),
            VWidgetsAccountSettingsCard(
              title: "Gender",
              subtitle: user.gender?.simpleName ?? Gender.any.simpleName,
              onTap: () {
                navigateToRoute(
                    context,
                    GenderFieldDropdown(
                      title: "Gender",
                      value: user.gender ?? Gender.any,
                      // pk: _userPK,
                      pk: user.id!,
                      dropdownIdentifyValue: dropdownIdentifyValue,
                    ));
              },
            ),
            // VWidgetsAccountSettingsCard(
            //   title: "Ethnicity",
            //   subtitle: user.ethnicity?.simpleName ?? '',
            //   onTap: () {
            //     navigateToRoute(
            //         context,
            //         ProfileDropdownInput(
            //           title: "Ethnicity",
            //           value: user.ethnicity,
            //           options: Ethnicity.values,
            //           onSave: (newValue) async {
            //             await ref
            //                 .read(appUserProvider.notifier)
            //                 .updateProfile(ethnicity: newValue);
            //           },
            //         ));
            //   },
            // ),
            // if (!user.isBusinessAccount!)
            VWidgetsAccountSettingsCard(
              title: "Experience Level",
              subtitle: user.label ?? '',
              onTap: () async {
                subTalentList = await allUserTypes?.getSubTalents(user.userType ?? '', isBusiness: user.isBusinessAccount!) ?? [];
                logger.d(subTalentList);

                if (context.mounted) {
                  // String label = user.label ?? '';
                  // if (user.label == null && subTalentList.isNotEmpty) {
                  //   label = subTalentList.first;
                  // }

                  navigateToRoute(
                      context,
                      ProfileDropdownInput(
                        title: "Experience Level",
                        value: user.label,
                        yearsOfExperience: user.yearsOfExperience,
                        options: subTalentList,
                        onSave: (newValue) async {
                          await ref.read(appUserProvider.notifier).updateProfile(label: newValue);
                        },
                      ));
                }
              },
            ),
            VWidgetsAccountSettingsCard(
              title: "Interest",
              subtitle: user.interests == null ? "" : user.interests!.join(", "),
              onTap: () async {
                subTalentList = await allUserTypes?.getSubTalents(user.userType ?? '', isBusiness: user.isBusinessAccount!) ?? [];
                logger.d(subTalentList);
                if (context.mounted) {
                  navigateToRoute(context, InterestSelectionDialog());
                }
              },
            ),
            // VWidgetsAccountSettingsCard(
            //   title: "Personality",
            //   subtitle: VConstants.userPersonalities.first,
            //   onTap: () {
            //     navigateToRoute(
            //         context,
            //         ProfileDropdownInput(
            //           title: "Personality",
            //           value: VConstants.userPersonalities.first,
            //           options: VConstants.userPersonalities,
            //           onSave: (newValue) async {},
            //         ));
            //   },
            // ),
            // addVerticalSpacing(10),
            // DropdownButtonHideUnderline(
            //   child: DropdownButton<String>(
            //     isExpanded: true,
            //     hint: Text("--Select a sub profile--"),
            //     borderRadius: BorderRadius.circular(10),
            //     value: _selectedSubProfile,
            //     onChanged: (String? newValue) => onDropDown(newValue!),
            //     items:
            //         subTalentList.map<DropdownMenuItem<String>>((String value) {
            //       return DropdownMenuItem<String>(
            //         value: value,
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 10),
            //           child: Text(value),
            //         ),
            //       );
            //     }).toList(),
            //   ),
            // ),
            if (user.isBusinessAccount!)
              VWidgetsAccountSettingsCard(
                title: "Website",
                subtitle: user.website ?? '',
                onTap: () {
                  navigateToRoute(
                      context,
                      ProfileInputField(
                        validator: (val) {
                          if (val.toString().isEmpty) {
                            return 'Field cannot be blank';
                          }
                          return null;
                        },
                        title: "Website",
                        value: user.website ?? '',
                        onSave: (newValue) async {
                          await ref.read(appUserProvider.notifier).updateProfile(website: newValue);
                        },
                      )
                      // ProfileInputField(
                      //   title: "Website",
                      //   value: user.website ?? '',
                      //   isBio: true,
                      //   onSave: (newValue) async {
                      //     await ref
                      //         .read(appUserProvider.notifier)
                      //         .updateProfile(website: newValue);
                      //   },
                      // ),
                      );
                },
              ),

            // if (!(user.isBusinessAccount ?? false))
            //   Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             "Display star sign",
            //             style: Theme.of(context).textTheme.displayLarge!.copyWith(
            //                   fontWeight: FontWeight.w500,
            //                 ),
            //           ),
            //           VWidgetsSwitch(
            //               swicthValue: _value,
            //               onChanged: (value) async {
            //                 _value = value;
            //                 setState(() {});
            //                 await ref.read(appUserProvider.notifier).toggleZodiac(value ? 'YES' : 'NO');
            //               }),
            //         ],
            //       ),
            //       addHorizontalSpacing(4),
            //       const Divider(
            //         thickness: 0.5,
            //       ),
            //     ],
            //   ),
            // addVerticalSpacing(10),
            // VWidgetsAccountSettingsCard(
            //   title: "More Information",
            //   subtitle: "",
            //   onTap: () {
            //     navigateToRoute(
            //         context,
            //         TwoFieldDropdown(
            //           title: "More Information",
            //           pk: user.id ?? 0,
            //         ));
            //   },
            // ),
            addVerticalSpacing(24),
          ],
        ),
      ),
    );
  }

  onDropDown(String s) {
    //print("object");
    _selectedSubProfile = s;
    setState(() {});
  }
}

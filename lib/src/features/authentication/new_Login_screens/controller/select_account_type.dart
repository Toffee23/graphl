import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/Loader.dart';
import 'package:vmodel/src/core/utils/extensions/strings.dart';
import 'package:vmodel/src/features/authentication/new_Login_screens/repository/account_type.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/empty_page/empty_page.dart';
import 'package:vmodel/src/vmodel.dart';

Map<String, Map<String, List<String>>> convertToDesiredFormat(Map jsonData) {
  Map<String, Map<String, List<String>>> result = {};

  jsonData.forEach(
    (key, value) {
      if (value is Map) {
        Map<String, List<String>> innerMap = {};
        value.forEach((innerKey, innerValue) {
          if (innerValue is List) {
            // Directly assign if it's a list of strings
            innerMap[innerKey] = List<String>.from(innerValue);
          } else if (innerValue is Map) {
            // Handle special case like `petModel`
            // You might want to flatten this or handle it differently
          }
          // Handle empty arrays or other special cases as needed
        });
        result[key] = innerMap;
      }
    },
  );

  return result;
}

Future<T?> showAccountTypeSelection<T>({
  required BuildContext context,
}) async {
  var accountProvider =
      FutureProvider((ref) => AccountTypeRepository.instance.getAccountType());
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final account = ref.watch(accountProvider);
          return account.when(
            skipLoadingOnRefresh: false,
            data: (data) {
              var userTypes = convertToDesiredFormat(data['userTypes'] as Map);
              var typeList = userTypes.keys.toList();
              typeList.removeWhere((element) => element.contains('__'));
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Select your preference',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...typeList.map(
                            (e) => ListTile(
                              onTap: () => Navigator.of(context).pop(
                                (e, userTypes[e]),
                              ),
                              title: Text('$e'.capitalize!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            error: (error, trace) => Center(
              child: EmptyPage(
                svgSize: 30,
                svgPath: VIcons.aboutIcon,
                // title: 'No Galleries',
                subtitle: 'Tap to refresh',
                onTap: () => ref.invalidate(accountProvider),
              ),
            ),
            loading: () => Center(
              child: Loader(),
            ),
          );
        },
      );
    },
  );
}

Future<T?> showAccountTypeOfIam<T>({
  required BuildContext context,
}) async {
  var accountProvider =
      FutureProvider((ref) => AccountTypeRepository.instance.getAccountType());
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          final account = ref.watch(accountProvider);
          return account.when(
            skipLoadingOnRefresh: false,
            data: (data) {
              var userTypes = convertToDesiredFormat(data['userTypes'] as Map);
              List typeList = userTypes.keys.toList();
              Map<String, List<String>> types = {};
              typeList.removeWhere((element) => element.contains('__'));
              List content = [];
              for (var u in typeList) {
                if (userTypes[u] != null) if (userTypes[u]!.isNotEmpty) {
                  var d = userTypes[u]!.keys.toList();
                  d.removeWhere((element) => element.contains('__'));
                  try {
                    types.addAll(userTypes[u]!);
                  } catch (e) {}
                  content.addAll(d);
                }
              }
              return Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    'Select account type',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...content.map(
                            (e) => ListTile(
                              onTap: () {
                                return Navigator.of(context).pop((e, types[e]));
                              },
                              title: Text(
                                '$e'.capitalize!.toType()!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
            error: (error, trace) => Center(
              child: EmptyPage(
                svgSize: 30,
                svgPath: VIcons.aboutIcon,
                // title: 'No Galleries',
                subtitle: 'Tap to refresh',
                onTap: () => ref.invalidate(accountProvider),
              ),
            ),
            loading: () => Center(
              child: Loader(),
            ),
          );
        },
      );
    },
  );
}

// Future<T?> showAccountTypeOfIam<T>({
//   required BuildContext context,
//   required Map<String, List<String>> types,
// }) async {
//   return showModalBottomSheet(
//     context: context,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(20),
//     ),
//     builder: (context) {
//       return Column(
//         children: [
//           SizedBox(
//             height: 40,
//           ),
//           Text(
//             'Select account type',
//             style: Theme.of(context).textTheme.displayMedium!.copyWith(
//                   fontWeight: FontWeight.w800,
//                   color: Theme.of(context).primaryColor,
//                 ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ...types.keys.map(
//                     (e) => ListTile(
//                       onTap: () => Navigator.of(context).pop((e, types[e])),
//                       title: Text('$e'.capitalize!),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       );
//     },
//   );
// }

Future<T?> showSubCategoryOfAccount<T>({
  required BuildContext context,
  required List<String> types,
}) async {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    builder: (context) {
      return Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Text(
            'Choose sub category',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...types.map(
                    (e) => ListTile(
                      onTap: () => Navigator.of(context).pop(e),
                      title: Text('$e'.capitalize!),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    },
  );
}

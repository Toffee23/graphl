// This file is not used anywhere in the file, I left it just incase
// Something comes up

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:vmodel/src/features/authentication/new_Login_screens/views/login_screen.dart';

// import '../../../../core/controller/app_user_controller.dart';
// import '../../../../core/utils/enum/auth_enum.dart';
// import '../../../../vmodel.dart';
// import '../../../dashboard/dash/dashboard_ui.dart';
// import '../../controller/auth_status_provider.dart';
// import '../../register/views/location_set_up.dart';

// class GoAuthWidgetPage extends ConsumerStatefulWidget {
//   const GoAuthWidgetPage({super.key});

//   static const path = "goAuthWidget";
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _GoAuthWidgetPageState();
// }

// class _GoAuthWidgetPageState extends ConsumerState<GoAuthWidgetPage> {
//   @override
//   Widget build(BuildContext context) {
//     ref.watch(invalidateStaleDataProvider);


//     ref.listen(authenticationStatusProvider, ((previous, next) {
//     }));

//     ref.watch(invalidateStaleDataProvider);


//     ref.listen(appUserProvider, ((previous, next) {
//     }));
//     ref.listen(authenticationStatusProvider, ((previous, next) {
//     }));
//     final tto = ref.watch(authenticationStatusProvider);

//     return tto.maybeWhen(
//       data: (status) {
//         switch (status) {
//           case AuthStatus.authenticated:
//             return const DashBoardView(navigationShell: null,);
//           case AuthStatus.firstLogin:
//             return const SignUpLocationViews();
//           default:
//             //User can sign up or sign in
//             return const OnBoardingPage();
//         }
//       },
//       //User can sign up or sign in
//       orElse: () => const OnBoardingPage(),
//     );
//   }
// }

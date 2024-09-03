


import 'package:go_router/go_router.dart';

class NavigationModel {
  StatefulNavigationShell? _navigationModel;
  StatefulNavigationShell? get navigationModel=>_navigationModel;
  set navigationModel(StatefulNavigationShell? _){
    _navigationModel = _;
  }
}
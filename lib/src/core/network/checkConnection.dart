//checking internet connection
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkConnection() async {
  bool check;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.other) {
    check = true;
  } else {
    check = false;
  }
  return check;
}

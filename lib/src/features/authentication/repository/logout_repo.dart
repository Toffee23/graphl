import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class LogoutRepository {
  LogoutRepository._();
  static LogoutRepository instance = LogoutRepository._();
  Future<Either<CustomException, Map<String, dynamic>>> logout(
      {required String fcmToken}) async {
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
mutation logoutUser(\$fcmToken: String!) {
  logoutUser(fcmToken: \$fcmToken) {
    message
  }
}
        ''', payload: {'fcmToken': fcmToken});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        
        return Right(right!['logoutUser']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

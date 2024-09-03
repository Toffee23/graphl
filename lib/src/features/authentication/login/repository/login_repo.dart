import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/features/authentication/login/models/device_info_model.dart';

final loginRepoInstance = LoginRepository.instance;

class LoginRepository {
  LoginRepository._();
  static LoginRepository instance = LoginRepository._();
  Future<Either<CustomException, Map<String, dynamic>>> loginWithEmail(
    String email,
    String password,
    String operatingSystem,
    String deviceName,
  ) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation TokenAuth(\$email: String, \$password: String!, \$operatingSystem: String, \$deviceName: String) {
            tokenAuth(email: \$email, password: \$password, operatingSystem: \$operatingSystem, deviceName: \$deviceName) {
              success
              use2fa
              token
              restToken
              errors
              user{
                username
                lastName
                firstName
                isActive
                bio
                id
                pk
               }
            }
          }
        ''', payload: {
        'email': email,
        'password': password,
        "operatingSystem": operatingSystem,
        "deviceName": deviceName,
      });

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        return Right(right!['tokenAuth']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException('${e.toString()} \n ${StackTrace.current}'));
      // return Left(CustomException(e.toString()));
    }
  }

  //make a call to loginwith username

  Future<Either<CustomException, Map<String, dynamic>>> loginWithUserName(String username, String password, DeviceInfoModel deviceInfo) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
         mutation TokenAuth(\$username: String!, \$password: String!,\$operatingSystem: String, \$deviceName: String) {
            tokenAuth(username: \$username, password: \$password,  operatingSystem: \$operatingSystem, deviceName: \$deviceName) {
              success
              use2fa
              token
              restToken
              errors
              user{
                username
                lastName
                firstName
                isActive
                bio
                id
                #pk
               }
            }
          }
        ''', payload: {
        'username': username,
        'password': password,
        "operatingSystem": deviceInfo.OS,
        "deviceName": deviceInfo.deviceName,
      });

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['tokenAuth']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException('${e.toString()} \n ${StackTrace.current}'));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> verify2FACode({required String code, String? username, String? email}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation verify2FAOtpCod(\$code: String!, \$email: String,\$username: String) {
              verifyOtpCode(code: \$code, email: \$email, username: \$username) {
                token
                restToken
                message
                user {
                  username
                }
              }
            }
        ''', payload: {
        'code': code,
        'username': username,
        'email': email,
      });

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        return Right(right!['verifyOtpCode']);
      });

      return userName;
    } catch (e) {
      return Left(CustomException('${e.toString()} \n ${StackTrace.current}'));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> socialAuth(String provider, String accessToken, String? firstName, String? lastName, bool isBusinessAccount, String userType) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(
          mutationDocument: '''
          mutation SocialAuth(\$provider: String!, \$accessToken: String!,\$firstName: String,\$lastName: String,\$isBusinessAccount: Boolean,\$userType: String) {
           socialAuth(provider: \$provider, accessToken: \$accessToken,firstName: \$firstName,lastName: \$lastName,isBusinessAccount: \$isBusinessAccount, userType: \$userType ) {
               social{
                 id
                 provider
                 uid
                 extraData
                 created
                 modified
               }
               restToken
               token
               user{
                 id
                 firstName
                 lastName
               }
            }
           }
        ''',
          payload: firstName == null && lastName == null
              ? {
                  'provider': provider,
                  'accessToken': accessToken,
                }
              : {
                  'provider': provider,
                  'accessToken': accessToken,
                  'firstName': firstName,
                  'lastName': lastName,
                  'isBusinessAccount': isBusinessAccount,
                  'userType': userType,
                });
      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) {
        return Left(left);
      }, (right) => Right(right!['socialAuth']));

      return userName;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class ManuallyUploadedVideos {
  ManuallyUploadedVideos._();
  static ManuallyUploadedVideos instance = ManuallyUploadedVideos._();

  Future<Either<CustomException, List<dynamic>>> getVideos() async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
        query getVideos {
          urlResources
        }
        ''', payload: {});

      return result.fold((left) {
       
        return Left(left);
      }, (right) {
        
        return Right(right!['urlResources'] as List);
      });
    } catch (e) {
      
      return Left(CustomException(e.toString()));
    }
  }
}

import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

import '../model/live_class_type.dart';

class LiveClassRepository {
  LiveClassRepository._();
  static LiveClassRepository instance = LiveClassRepository._();

  Future<Either<CustomException, String>> createLiveClass({required LiveClassesInput liveClassInput}) async {
    try {
      final response = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
mutation CreateLiveClass(
  \$title: String!,
  \$liveType: LiveTypeEnum!, 
  \$description: String!,
  \$price: Float!,
  \$startTime: DateTime!,
  \$duration: Int!,
  \$preparation: String,
  \$classDifficulty: ClassDifficultyEnum!,
  \$category: [String],
  \$banners: [String],
  \$timeline: [LiveClassTimelineInput]
  ) {
   createLiveClass(
    liveClassData: {
      title: \$title,
      liveType: \$liveType,
      description: \$description,
      price: \$price,
      startTime: \$startTime,
      duration: \$duration,
      preparation: \$preparation,
      classDifficulty: \$classDifficulty,
      category: \$category,
      banners: \$banners,
      timeline: \$timeline,
    }
  ) {
    success
    message
  }
}
''',
        payload: liveClassInput.toJson(),
      );
      final Either<CustomException, String> result = response.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createLiveClass']['message']);
      });
      return result;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> getUpcomingLives({
    required String? liveType,
    required String search,
    required String category,
    required String duration,
    required bool upcoming,
    required int pageCount,
    required int pageNumber,
  }) async {
    try {
      final response = await vBaseServiceInstance.getQuery(
        queryDocument: '''
query GetAllLiveClasses(
  \$liveType: LiveTypeEnum,
  \$search: String,
  \$category: String,
  \$duration: String,
  \$upcoming: Boolean,
  \$pageCount: Int,
  \$pageNumber: Int,
  ) {
   allLiveClasses(
    liveType: \$liveType,
    search: \$search,
    category: \$category,
    duration: \$duration,
    upcoming: \$upcoming,
    pageCount: \$pageCount,
    pageNumber: \$pageNumber,
  ) {
    id
    title
    liveType
    user{
      id
      reviewStats{
        noOfReviews
        rating
      }
      username
      profilePicture
    }
    description
    price
    startTime
    duration
    preparation
    classDifficulty
    category
    banners
  }
  allLiveClassesTotalNumber
}
''',
        payload: {
          'liveType': liveType,
          'search': search,
          'category': category,
          'duration': duration,
          'upcoming': upcoming,
          'pageCount': pageCount,
          'pageNumber': pageNumber,
        },
      );
      final Either<CustomException, Map<String, dynamic>> result = response.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
      return result;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> myLiveClasses({
    required String search,
    required String category,
    required String duration,
    required bool upcoming,
    required int pageCount,
    required int pageNumber,
  }) async {
    try {
      final response = await vBaseServiceInstance.getQuery(
        queryDocument: '''
query myLiveClasses(
  \$search: String
  \$category: String
  \$duration: String
  \$upcoming: Boolean
  \$pageCount: Int
  \$pageNumber: Int
  ) {
   myLiveClasses(
    search: \$search,
    category: \$category,
    duration: \$duration,
    upcoming: \$upcoming,
    pageCount: \$pageCount,
    pageNumber: \$pageNumber,
  ) {
    id
    title
    liveType
    user{
      id
      reviewStats{
        noOfReviews
        rating
      }
      username
      profilePicture
    }
    description
    price
    startTime
    duration
    preparation
    classDifficulty
    category
    banners
  }
  myLiveClassesTotalNumber
}
''',
        payload: {
          'search': search,
          'category': category,
          'duration': duration,
          'upcoming': upcoming,
          'pageCount': pageCount,
          'pageNumber': pageNumber,
        },
      );
      final Either<CustomException, Map<String, dynamic>> result = response.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
      return result;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

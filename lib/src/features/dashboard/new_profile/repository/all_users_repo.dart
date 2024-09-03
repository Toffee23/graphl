import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';

import '../../../../core/utils/exception_handler.dart';

class AllUsersRepository {
  AllUsersRepository._();
  static AllUsersRepository instance = AllUsersRepository._();

  Future<Either<CustomException, List>> getUsers() async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
 query(\$pageCount: Int, \$pageNumber: Int){
  getUsers(
    pageCount: \$pageCount,
    pageNumber: \$pageNumber,
  ){
    username
    id
    email
    bio
    gender
    userType
    postcode
    gender
    firstName
    lastName
    hair
    eyes
    profilePictureUrl
    location{
      id
      latitude
      longitude
    }
  }
}

      ''',
        payload: {"pageCount": null, "pageNumber": null},
      );

      final Either<CustomException, List> getUsersResult = result.fold(
        (left) => Left(left),
        (right) {
          final getUsers = right?['getUsers'] as List?;
          //print(getUsers);
          return Right(getUsers!);
        },
      );

      return getUsersResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List>> getLives(String username) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
 query(\$username: String!){
  getUser(
    username: \$username,
  ){
    liveclassSet{
    id
    category
    title
    price
    duration
    description
    liveType
    startTime
    preparation
    classDifficulty
    banners
    timelines{
      step
      title
      description
      duration
    }
    user{
      username
      profilePicture
     }
    }
  }
}

      ''',
        payload: {"username": username},
      );

      final Either<CustomException, List> getUserLivesResult = result.fold(
        (left) {
          return Left(left);
        },
        (right) {
          final getUserLives = right?['getUser']['liveclassSet'] as List?;
          return Right(getUserLives!);
        },
      );

      return getUserLivesResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

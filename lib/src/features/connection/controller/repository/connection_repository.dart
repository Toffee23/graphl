import 'dart:developer';

import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

abstract class ConnectionRepository {
  Future<Either<CustomException, Map<String, dynamic>>> requestConnection(String username);
  Future<Either<CustomException, Map<String, dynamic>>> deleteConnection(int connectionId);
  Future<Either<CustomException, Map<String, dynamic>>> updateConnection(bool accept, int connectionId);
  Future<Either<CustomException, Map<String, dynamic>>> rejectConnection(bool accept, int connectionId);
  Future<Either<CustomException, List<dynamic>>> getUserConnections(String? username);
  Future<Either<CustomException, List<dynamic>>> getSentConnectionsRequests({String? search});
  Future<Either<CustomException, List<dynamic>>> getRecievedConnectionsRequests({String? search});
  Future<Either<CustomException, List<dynamic>>> getConnections({bool? latestFirst});
  Future<Either<CustomException, List<dynamic>>> searchConnections({required String query});
}

class ConnectionsRepository implements ConnectionRepository {
  @override
  Future<Either<CustomException, Map<String, dynamic>>> requestConnection(String username) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation CreateConnection(\$username: String!) {
            createConnection(username: \$username) {
              success
              connection{
                id
                user{
               id
               firstName
               lastName
               displayName
               profileRing
               }
                connection{
               id
               firstName
               lastName
               displayName
               }
                accepted
                rejected
                createdAt
                updatedAt
                deleted
               }
            }
          }
        ''', payload: {'username': username});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        logger.f(right!['createConnection']);
        return Right(right['createConnection']);
      });

      return userName;
    } catch (e) {
      log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, Map<String, dynamic>>> rejectConnection(bool accept, int connectionId) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation UpdateConnection(\$accept: Boolean!, \$connectionId: Int!) {
            updateConnection(accept: \$accept, connectionId: \$connectionId,) {
              success
            }
          }
        ''', payload: {'accept': accept, 'connectionId': connectionId});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        //print('%%%%%%%%%%%%%%% $right');
        return Right(right!['tokenAuth']);
      });

      return userName;
    } catch (e) {
      log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, Map<String, dynamic>>> deleteConnection(int connectionId) async {
    logger.d(connectionId);
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation DeleteConnection(\$connectionId: Int!) {
            deleteConnection(connectionId: \$connectionId,) {
              success
            }
          }
        ''', payload: {'connectionId': connectionId});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        logger.f(right);
        return Right(right!);
      });

      return userName;
    } catch (e) {
      log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, Map<String, dynamic>>> updateConnection(bool accept, int connectionId) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation UpdateConnection(\$accept: Boolean!, \$connectionId: Int!) {
            updateConnection(accept: \$accept, connectionId: \$connectionId,) {
              success
            }
          }
        ''', payload: {'accept': accept, 'connectionId': connectionId});

      final Either<CustomException, Map<String, dynamic>> userName = result.fold((left) => Left(left), (right) {
        //print('%%%%%%%%%%%%%%% $right');
        return Right(right!['tokenAuth']);
      });

      return userName;
    } catch (e) {
      log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<dynamic>>> getConnections({bool? latestFirst}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query connections (\$pageCount: Int, \$pageNumber: Int,\$latestFirst: Boolean) {
        connections (pageCount:\$pageCount, pageNumber:\$pageNumber, latestFirst: \$latestFirst) {
              id
              firstName
              lastName
              username
              displayName
              profilePictureUrl
              thumbnailUrl
              isBusinessAccount
              userType
              label
              isVerified
              blueTickVerified
              profileRing
              connectionId
          }
              }
        ''', payload: {
        'pageCount': 20,
        'pageNumber': 1,
        'latestFirst': latestFirst,
      });
      //print('Results for get connections $result');

      final Either<CustomException, List<dynamic>> response = result.fold((left) => Left(left), (right) {
        logger.d(right);
        final albumList = right?['connections'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<dynamic>>> getUserConnections(String? username) async {
    //print('Get user connections');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query userConnections (\$username: String!, \$pageCount: Int, \$pageNumber: Int) {
  userConnections (username: \$username, pageCount:\$pageCount, pageNumber:\$pageNumber) {
    id
               firstName
               lastName
               username
               displayName
               thumbnailUrl
               profilePictureUrl
               isBusinessAccount
               userType
               label
              isVerified
              blueTickVerified
              profileRing
                }
}
        ''', payload: {
        'username': username,
        'pageCount': 20,
        'pageNumber': 1,
      });
      //print('Results for get user connections $result');

      final Either<CustomException, List<dynamic>> response = result.fold((left) => Left(left), (right) {
        // //print("77777777777777777777777777777777 $right");

        final albumList = right?['userConnections'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<dynamic>>> getSentConnectionsRequests({String? search}) async {
    //print('Fetching sent connection requests');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query connectionRequests (\$requestType: String!, \$pageCount: Int,
       \$pageNumber: Int, \$search: String) {
  connectionRequests (requestType: \$requestType, pageCount:\$pageCount,
   pageNumber:\$pageNumber, search: \$search) {
    id
    user{
               id
               firstName
               lastName
               displayName
              isVerified
              blueTickVerified
              profileRing
               }
                connection{
               id
               firstName
               lastName
               username
               displayName
               thumbnailUrl
               profilePictureUrl
               isBusinessAccount
               userType
               label
              isVerified
              blueTickVerified
               }
                accepted
                rejected
                createdAt
                updatedAt
                
  }
}
        ''', payload: {
        'requestType': 'sent',
        'pageCount': 20,
        'pageNumber': 1,
        'search': search,
      });
      //print('Sent connection result $result');

      final Either<CustomException, List<dynamic>> response = result.fold((left) => Left(left), (right) {
        // //print("77777777777777777777777777777777 $right");

        final albumList = right?['connectionRequests'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<dynamic>>> getRecievedConnectionsRequests({String? search}) async {
    //print('Fetching received connection requests');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
       query connectionRequests (\$requestType: String!, \$pageCount: Int,
        \$pageNumber: Int, \$search: String) {
  connectionRequests (requestType: \$requestType, pageCount:\$pageCount,
   pageNumber:\$pageNumber, search: \$search) {
    id
    user{
               id
               firstName
               lastName
               username
               displayName
               thumbnailUrl
               profilePictureUrl
               userType
               label
               isBusinessAccount
              isVerified
              blueTickVerified
              profileRing
               }
                connection{
               id
               firstName
               lastName
               username
               displayName
               thumbnailUrl
               profilePictureUrl
               isBusinessAccount
               userType
               label
              isVerified
              blueTickVerified
               }
                accepted
                rejected
                createdAt
                updatedAt
                
  }
}
        ''', payload: {
        'requestType': 'received',
        'pageCount': 20,
        'pageNumber': 1,
        'search': search,
      });
      //print('Results for received connection requests $result');

      final Either<CustomException, List<dynamic>> response = result.fold((left) => Left(left), (right) {
        // //print("77777777777777777777777777777777 $right");

        final albumList = right?['connectionRequests'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  @override
  Future<Either<CustomException, List<dynamic>>> searchConnections({required String query}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''

query searchConnection(\$search: String) {
  connections(search: \$search) {
    id
    username
    firstName
    lastName
    displayName
    isBusinessAccount
    userType
    label
    isVerified
    blueTickVerified
    thumbnailUrl
    profilePictureUrl
    profileRing
  }
}
        ''', payload: {
        // 'pageCount': 20,
        // 'pageNumber': 1,
        'search': query,
      });

      final Either<CustomException, List<dynamic>> response = result.fold((left) => Left(left), (right) {
        //print("7[77] search results for $query ==] $right");

        final results = right?['connections'] as List<dynamic>?;
        return Right(results ?? []);
      });

      // //print("''''''''''''''''''''''''''''''$response");
      return response;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

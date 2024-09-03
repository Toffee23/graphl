import 'package:either_option/either_option.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';
import 'package:vmodel/src/core/utils/logs.dart';

class VBaseService {
  VBaseService._();
  static VBaseService vBaseService = VBaseService._();
//Query(Same as Get request)
  Future<Either<CustomException, Map<String, dynamic>?>> getQuery(
      {required String queryDocument,
      required Map<String, dynamic> payload}) async {
    Either<CustomException, Map<String, dynamic>?> response;
    final request = await graphQLConfigInstance.client().query(QueryOptions(
          document: gql(queryDocument),
          variables: payload,
        ));
    if (request.hasException) {
      if (request.exception?.linkException is ServerException) {
        logger.e(request.exception.toString(),
            stackTrace: request.exception?.originalStackTrace);
        response = Left(CustomException('An error occured'));
      } else {
        response = Left(CustomException(
            request.exception!.graphqlErrors[0].message.toString()));
      }
    } else {
      response = Right(request.data);
    }

    return response;
  }

//Mutation(Same as Post request)
  Future<Either<CustomException, Map<String, dynamic>?>> mutationQuery(
      {required String mutationDocument,
      required Map<String, dynamic> payload}) async {
    Either<CustomException, Map<String, dynamic>?> response;
    final request = await graphQLConfigInstance.client().mutate(
        MutationOptions(document: gql(mutationDocument), variables: payload));

    if (request.hasException) {
      // 'Mutation:  $mutationDocument \n'
      if (request.exception?.linkException == null) {
        var errMsg = request.exception!.graphqlErrors.first.message;
        logger.e(request.exception.toString());
        response = Left(CustomException(errMsg));
      } else {
        if (request.exception?.linkException is ServerException) {
          logger.e(request.exception.toString(),
              stackTrace: request.exception?.originalStackTrace);
          response = Left(CustomException('An error occured!'));
        } else {
          logger.e(request.exception.toString(),
              stackTrace: request.exception?.originalStackTrace);
          response = Left(CustomException(
              request.exception!.graphqlErrors[0].message.toString()));
        }
      }
    } else {
      response = Right(request.data);
    }

    return response;
  }

  //muation without options

  //Mutation(Same as Post request)
  Future<Map<String, dynamic>?> mutateOrdinaryQuery(
      {required String mutatonDocument,
      required Map<String, dynamic> payload}) async {
    final request = await graphQLConfigInstance.client().mutate(
        MutationOptions(document: gql(mutatonDocument), variables: payload));
    return request.data;
  }

  Future<QueryResult<Object?>> mutateOrdinaryQueryWithResult(
      {required String mutatonDocument,
      required Map<String, dynamic> payload}) async {
    final request = await graphQLConfigInstance.client().mutate(
        MutationOptions(document: gql(mutatonDocument), variables: payload));
    return request;
  }

  //query

  //Query(Same as Get request)
  Future<Map<String, dynamic>?> getOrdinaryQuery(
      {required String queryDocument,
      required Map<String, dynamic> payload}) async {
    final request = await graphQLConfigInstance.client().query(QueryOptions(
          document: gql(queryDocument),
          variables: payload,
        ));

    return request.data;
  }
}

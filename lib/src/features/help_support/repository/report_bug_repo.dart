import 'dart:io';

import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/api/file_service.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class TicketRepository {
  TicketRepository._();
  static TicketRepository instance = TicketRepository._();

  /// Reporting a BUG
  Future<Either<CustomException, Map<String, dynamic>>> reportBug(
      {required String details, required String phoneType, required String osVersion}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              mutation createBug(\$details:String!, \$osVersion:String!, \$phoneType: String!){
  createBug(
    details: \$details
    osVersion: \$osVersion
    phoneType: \$phoneType
  ) {
    message
  }
}
      ''',
        payload: {
          'phoneType': phoneType,
          'osVersion': osVersion,
          'details': details
        },
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult =
      result.fold(
            (left) => Left(left),
            (right) {
          //print(right);
          final getReportResul =
          right?['createBug'] as Map<String, dynamic>?;

          return Right(getReportResul!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  /// Reporting an ABUSE
  Future<Either<CustomException, Map<String, dynamic>>> reportAccount(
      {required String details, required String username, required String reason}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              mutation reportAccount(\$content:String, \$reason:String!, \$username: String!){
  reportAccount(
    content: \$content
    reason: \$reason
    username: \$username
  ) {
    message
  }
}

      ''',
        payload: {
          'reason': reason,
          'username': username,
          'content': details
        },
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult =
      result.fold(
            (left) => Left(left),
            (right) {
          //print(right);
          final getReportResul =
          right?['reportAccount'] as Map<String, dynamic>?;

          return Right(getReportResul!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  /// Creating a TICKET
  Future<Either<CustomException, Map<String, dynamic>>> createTicket(
      {required String attachment, required String report, required String subject}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              mutation createTicket(\$attachment:String, \$report:String!, \$subject: String!){
  createTicket(
    attachment: \$attachment
    report: \$report
    subject: \$subject
  ) {
    message
  }
}
      ''',
        payload: {
          'attachment': attachment,
          'report': report,
          'subject': subject
        },
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult =
      result.fold(
            (left) => Left(left),
            (right) {
          //print(right);
          final getTicketResult =
          right?['createTicket'] as Map<String, dynamic>?;

          return Right(getTicketResult!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  /// Reporting an ABUSE
  Future<Either<CustomException, Map<String, dynamic>>> getMyTickets(
      {required int pageCount, required int pageNumber}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
              query userTickets(\$pageCount:Int, \$pageNumber:Int){
  userTickets(
    pageCount: \$pageCount
    pageNumber: \$pageNumber
  ) {
    id
    user {
      id
      lastName
      firstName
      username
      userType
      label
      email
      bio
      profilePicture
      profilePictureUrl
      gender
      thumbnailUrl
      isBusinessAccount
      userType
      label
    }
    subject
    issue
    attachment
    status
    dateCreated
  }
  userTicketsTotalNumber
}

      ''',
        payload: {
          'pageCount': pageCount,
          'pageNumber': pageNumber
        },
      );

      final Either<CustomException, Map<String, dynamic>> getReportResult =
      result.fold(
            (left) => Left(left),
            (right) {
          //print(right);
          final getTicketResul = right;

          return Right(getTicketResul!);
        },
      );

      return getReportResult;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  ///Upload image

  Future<Either<CustomException, String?>> uploadFiles(
      String url, List<File?>? files,
      {OnUploadProgressCallback? onUploadProgress}) async {
    final fps = files!.map((e) => e!.path).toList();
    try {
      final res = await FileService.fileUploadMultipart(
        // url: VUrls.postMediaUploadUrl,
        url: url,
        files: fps,
        onUploadProgress: onUploadProgress,
      );
      // return res;
      //print('%%%MMMMMMMMM Returning right $res');
      return Right(res);
    } catch (e) {
      //print("Here error uploading url: $url \n $e");
      return Left(CustomException(e.toString()));
    }
  }


}

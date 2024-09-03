import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:either_option/either_option.dart';

// import 'package:get/get.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/api/file_service.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class CreatePostRepository {
  CreatePostRepository._();

  static CreatePostRepository instance = CreatePostRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> postContent({
    required String albumId,
    required String aspectRatio,
    String? locationInfo,
    required String caption,
    required List<Map<String, dynamic>> filesMap,
    required List<String> tagged,
    required int? serviceId,
  }) async {
    //print('+-) tagged users $tagged');
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
         mutation createPost(\$albumId: Int!, \$aspectRatio: String!, \$caption: String, 
\$files: [FileUrlType]!,
\$locationInfo: String,
\$tagged: [String],
\$serviceId: Int) {
  createPost(album: \$albumId,
    aspectRatio: \$aspectRatio,
    caption: \$caption,
    files: \$files,
    locationInfo: \$locationInfo,
    tagged: \$tagged,
    service: \$serviceId,
    ) {
    status
    message
    userPost {
      id
      hasVideo
      media {
        id
        itemLink
        description
            }
        }
    }
} 
          
        ''', payload: {
        'albumId': albumId, //Album id for Emo
        'caption': caption,
        'files': filesMap,
        'locationInfo': locationInfo,
        'tagged': tagged,
        'aspectRatio': aspectRatio,
        'serviceId': serviceId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createPost']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> postVideoContent({
    required String albumId,
    required String aspectRatio,
    String? locationInfo,
    required String caption,
    required List<Map<String, dynamic>> filesMap,
    required List<String> tagged,
    required int? serviceId,
  }) async {
    //print('+-) tagged users $tagged');
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
         mutation createPost(\$albumId: Int!, \$aspectRatio: String!, \$caption: String, 
            \$files: [FileUrlType]!,
            \$locationInfo: String,
            \$tagged: [String],
            \$serviceId: Int) {
              createPost(album: \$albumId,
                aspectRatio: \$aspectRatio,
                caption: \$caption,
                files: \$files,
                locationInfo: \$locationInfo,
                tagged: \$tagged,
                service: \$serviceId,
                ) {
                status
                message
                userPost {
                  id
                  hasVideo
                  media {
                    id
                    itemLink
                    description
                        }
                    }
                }
            } 
          
        ''', payload: {
        'albumId': albumId, //Album id for Emo
        'caption': caption,
        'files': filesMap,
        'locationInfo': locationInfo,
        'tagged': tagged,
        'aspectRatio': aspectRatio,
        'serviceId': serviceId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createPost']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> uploadPhotoThumbnail(
      {required String postId,
      required List<Map<String, dynamic>> data}) async {
    //print('The postId: $postId map is $data');
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
mutation UploadPhotoThumbnail(\$postId: String!,
  \$thumbnailUrl: [ThumbnailUrlType]!) {
  uploadPhotoThumbnail(postId: \$postId,
    thumbnailUrl: \$thumbnailUrl) {
    message
    post {
      id
      hasVideo
      media {
        id
        itemLink
        thumbnail
      }
    }
  }
}


''', payload: {"postId": postId, "thumbnailUrl": data});

      return result.fold((left) {
        return Left(left);
      }, (right) {
        //print('Sxuccess right $right');
        return Right(right!['uploadPhotoThumbnail']);
      });
    } catch (e) {
      //print(e);
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> editPost({
    required int postId,
    String? caption,
    String? locationName,
    List<String>? taggedUsers,
    String? serviceId,
  }) async {
    // final tagged =
    try {
      List<String> processedTaggedUsers = taggedUsers ?? [""];
      if (taggedUsers != null && taggedUsers.isNotEmpty) {
        processedTaggedUsers = taggedUsers;
      }

      final result = await vBaseServiceInstance.mutationQuery(
        mutationDocument: '''
      mutation updatePost(
        \$postId: Int!,
        \$caption: String,
        \$locationInfo: String,
        \$tagged: [String],
        \$serviceId: Int,
      ) {
        updatePost(
          postId: \$postId,
          caption: \$caption,
          locationInfo: \$locationInfo,
          tagged: \$tagged,
          serviceId: \$serviceId,
        ) {
          status
          message
          userPost {
            caption
            hasVideo
            locationInfo
            tagged {
              id
              username
            }
            service {
            id
            }
          }
        }
      }
      ''',
        payload: {
          "postId": postId,
          "caption": caption,
          "locationInfo": locationName,
          "tagged": processedTaggedUsers,
          // (taggedUsers != null && taggedUsers.isEmpty) ? [""] : taggedUsers,
          "serviceId": int.tryParse(serviceId ?? '')
        },
      );

      return result.fold(
        (left) => Left(left),
        (right) {
          return Right(right!);
        },
      );
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> postLocationHistory() async {
    // final tagged =
    try {
      final result = await vBaseServiceInstance.getQuery(
        queryDocument: '''
        {
          previousPostLocations
        }
      ''',
        payload: {},
      );

      return result.fold(
        (left) => Left(left),
        (right) {
          //print('[oxssi] $right');
          final res = right!['previousPostLocations'] as List?;
          return Right(res ?? []);
        },
      );
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> getAlbums(
      {String? username, String? albumType}) async {
    //print('CreatePostRepo Fetching albums for user $username');
    try {
      final result =
          await vBaseServiceInstance.mutationQuery(mutationDocument: '''
      query userAlbumsPosts (\$username: String, \$albumType: String) {
  userAlbums (username:\$username, albumType: \$albumType) {
              id
              name
              albumType
             }
           }
        ''', payload: {'username': username, 'albumType': albumType});

      final Either<CustomException, List<dynamic>> albumResponse =
          result.fold((left) => Left(left), (right) {
        //print("INside right ''''''''''''''''''''''''''''''");

        final albumList = right?['userAlbums'] as List<dynamic>?;
        return Right(albumList ?? []);
      });

      //print("''''''''''''''''''''''''''''''$albumResponse");
      return albumResponse;
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  //Upload file
  Future<Either<CustomException, String?>> uploadFiles(
      String url, List<File> files,
      {OnUploadProgressCallback? onUploadProgress,
      int maxRetries = 3,
      Duration retryDelay = const Duration(seconds: 2)}) async {
    // Validate input parameters
    if (url.isEmpty) {
      print(" ========= Upload URL cannot be empty.");
      return Left(CustomException("Upload URL cannot be empty."));
    }

    if (files.isEmpty) {
      print(" ========= No files provided for upload.");
      return Left(CustomException("No files provided for upload."));
    }

    final filePaths = files.map((file) => file.path).toList();

    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        // Perform file upload
        final response = await FileService.fileUploadMultipart(
          url: url,
          files: filePaths,
          onUploadProgress: onUploadProgress,
        );

        // Check if the response is valid
        if (response == null || response.isEmpty) {
          print(" ========= File upload failed. No response from server.");
          return Left(
              CustomException("File upload failed. No response from server."));
        }

        // Return the successful response
        return Right(response);
      } on TimeoutException catch (e) {
        print(" ========= File upload timed out: ${e.message}");
        return Left(CustomException("File upload timed out: ${e.message}"));
      } on SocketException catch (e) {
        print(" ========= Network error: ${e.message}");
        return Left(CustomException("Network error: ${e.message}"));
      } catch (e) {
        // Handle a 504 Gateway Timeout specifically with a retry mechanism
        if (e.toString().contains('504')) {
          attempt++;
          if (attempt < maxRetries) {
            print(" ========= Retry attempt $attempt due to 504 error.");
            await Future.delayed(retryDelay);
          } else {
            print(" ========= Max retries reached. Error: ${e.toString()}");
            return Left(
                CustomException("Max retries reached. Error: ${e.toString()}"));
          }
        } else {
          // Handle any other type of exception
          print(" ========= An unexpected error occurred: ${e.toString()}");
          return Left(
              CustomException("An unexpected error occurred: ${e.toString()}"));
        }
      }
    }

    // If the retries are exhausted
    return Left(
        CustomException("File upload failed after $maxRetries attempts."));
  }

  Future<Either<CustomException, String?>> uploadRawBytesList(
      String url, List<Uint8List> rawData,
      {OnUploadProgressCallback? onUploadProgress}) async {
    // final fps = files.map((e) => e.path).toList();
    //print('[video] upload url $url');
    try {
      final res = await FileService.rawBytesDataUploadMultipart(
        // url: VUrls.postMediaUploadUrl,
        url: url,
        rawDataList: rawData,
        onUploadProgress: onUploadProgress,
      );
      // return res;
      return Right(res);
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

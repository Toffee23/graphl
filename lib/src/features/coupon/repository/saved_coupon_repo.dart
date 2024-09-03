import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class SavedCouponRepository {
  SavedCouponRepository._();
  static SavedCouponRepository instance = SavedCouponRepository._();



  Future<Either<CustomException, List<dynamic>>> couponBoards(
      {
        required int pageCount,
        int? pageNumber,
      }
  ) async {
    try {
      final result =
      await vBaseServiceInstance.getQuery(queryDocument: '''
          query couponBoards(\$pageCount: Int, \$pageNumber: Int) {
            couponBoards(pageCount: \$pageCount,pageNumber:\$pageNumber ) {
              id
              title
              createdAt
              deleted
              numberOfCoupons
              pinned
              coupons{
                id
                code
              }
              pinnedCoupons{
                id
                code
              }
            }
          }
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });

      return result.fold((left) {
       
        return Left(left);
      }, (right) {
        return Right(right!['couponBoards']);
      });
    } catch (e) {
      
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> savedCoupons(
      {
        required int pageCount,
        int? pageNumber,
      }
  ) async {
    //print('pageCount is $pageCount && pageNumber is $pageNumber');
    try {
      final result =
      await vBaseServiceInstance.getQuery(queryDocument: '''
          query savedCoupons(\$pageCount: Int, \$pageNumber: Int) {
            savedCoupons(pageCount: \$pageCount,pageNumber:\$pageNumber ) {
            id
            deleted
            boardId
            createdAt
            coupon{
              id
              title
              code
            }
            }
          }
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
      });
      return result.fold((left) {
       
        return Left(left);
      }, (right) {
        final success = right!['savedCoupons'];
        return Right(right['savedCoupons']);
      });
    } catch (e) {
      
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, List<dynamic>>> boardCoupons(
      {
        required int pageCount,
        int? pageNumber,
        required int boardId,
      }
  ) async {
    try {
      final result =
      await vBaseServiceInstance.getQuery(queryDocument: '''
          query couponBoardCoupons(\$pageCount: Int, \$pageNumber: Int, \$boardId: Int!) {
            couponBoardCoupons(pageCount: \$pageCount,pageNumber:\$pageNumber,boardId:\$boardId, ) {
            id
            title
            code
            dateCreated
            copyCount
            saves
            deleted
            isExpired
          }
        ''', payload: {
        'pageCount': pageCount,
        'pageNumber': pageNumber,
        'boardId': boardId,
      });
      //print('result is:');
      //print(result);
      return result.fold((left) {
       
        return Left(left);
      }, (right) {
        final success = right!['couponBoardCoupons'];
        return Right(right['couponBoardCoupons']);
      });
    } catch (e) {
      
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createCouponBoard(
    String title,
  ) async {
    try {
      final result =
      await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation createCouponBoard(\$title: String!) {
            createCouponBoard(title: \$title) {
              couponBoard {
                id
              }
              
            }
          }
        ''', payload: {'title': title});

      return result.fold((left) {
       
        return Left(left);
      }, (right) {
        final success = right!['createCouponBoard'];
        //print('BBBB000000000000 right $right');
        return Right(right['createCouponBoard']);
      });
    } catch (e) {
      
      return Left(CustomException(e.toString()));
    }
  }


  Future<Either<CustomException, Map<String, dynamic>>> saveCoupon(
      {required int couponId, int? boardId}) async {
    try {
      final result =
      await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation saveCoupon(\$couponId:Int!, \$boardId: Int) {
            saveCoupon(couponId: \$couponId, boardId: \$boardId) {
              success
              message
            }
          }
        ''', payload: {'couponId': couponId, 'boardId': boardId});

      return result.fold(
              (left) => Left(left),
              (right) {
        return Right(right!['saveCoupon']);
      });
    } catch (e) {
      // log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }


  Future<Either<CustomException, Map<String, dynamic>>> deleteCoupon(
      {required int couponId}) async {
    try {
      final result =
      await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation deleteCoupon(\$couponId:Int!) {
            deleteCoupon(couponId: \$couponId) {
              message
            }
          }
        ''', payload: {'couponId': couponId});

      return result.fold(
              (left) => Left(left),
              (right) {
        return Right(right!['deleteCoupon']);
      });
    } catch (e) {
      // log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }


  Future<Either<CustomException, Map<String, dynamic>>> removeCouponBoard(
      {required int boardId}) async {
    try {
      final result =
      await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation removeCouponBoard(\$boardId:Int!) {
            removeCouponBoard(boardId: \$boardId) {
              message
            }
          }
        ''', payload: {'boardId': boardId});

      return result.fold(
              (left) => Left(left),
              (right) {
        return Right(right!['removeCouponBoard']);
      });
    } catch (e) {
      // log(e.toString());
      return Left(CustomException(e.toString()));
    }
  }

}

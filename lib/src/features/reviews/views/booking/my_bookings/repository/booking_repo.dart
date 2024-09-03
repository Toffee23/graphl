import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class BookingRepository {
  BookingRepository._();
  static BookingRepository instance = BookingRepository._();

  Future<Either<CustomException, Map<String, dynamic>>> myBookings({
    required int? pageCount,
    required int? pageNumber,
    String? module,
  }) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
        query myBookings(\$module: BookingModuleEnum, \$pageNumber: Int, \$pageCount: Int) {
          bookedMe(module: \$module, pageNumber: \$pageNumber, pageCount: \$pageCount) {
            id
            title
            price
            pricingOption
            bookingType
            module
            moduleId
            moduleUser {
              id
              username
            }
            status
            address
            haveBrief
            deliverableType
            expectDigitalContent
            usageType {
              id
              name
            }
            usageLength {
              id
              name
            }
            brief
            briefFile
            briefLink
            startDate
            dateCreated
            lastUpdated
            deleted
            user{
              id
              username
              profilePictureUrl
            }
            paymentSet {
              id
              amount
              paymentRef
              status
            }
          }
          bookedMeTotalNumber
        }

        ''', payload: {
        "module": module,
        "pageCount": pageCount,
        "pageNumber": pageNumber,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createBooking({required Map<String, dynamic> bookingData}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''

      mutation CreateBooking(\$bookingData: BookingInput!) {
        createBooking(bookingData: \$bookingData) {
          booking {
            id
            title
            usageType {
              id
              name
            }
          }
        }
      }

        ''', payload: {
        "bookingData": bookingData,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> singleBooking({required int bookingId}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
      query singleBooking(\$bookingId: Int!) {
        booking(bookingId: \$bookingId) {
          id
          title
          price
          pricingOption
          bookingType
          module
          moduleId
          moduleUser {
            id
            username
          }
          status
          address
          haveBrief
          deliverableType
          expectDigitalContent
          usageType {
            id
            name
          }
          usageLength {
            id
            name
          }
          brief
          briefFile
          briefLink
          startDate
          dateCreated
          lastUpdated
          deleted
          user{
            id
            username
            profilePictureUrl
          }
          paymentSet {
            id
            amount
            paymentRef
            status
          }
        }
      }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['booking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> createPayment({required int bookingId}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation GeneratePaymentIntent  (\$bookingId: Int!) {
              createPaymentIntent(bookingId: \$bookingId) {
                    paymentRef
                    clientSecret
              }
            }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['createPaymentIntent']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> confirmPayment({required String paymentRef}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
            mutation confirmPayment(\$paymentRef: String!) {
              confirmPayment(paymentRef: \$paymentRef) {
                paymentStatus
              }
            }
        ''', payload: {
        "paymentRef": paymentRef,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['confirmPayment']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> startBooking({required int bookingId}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation startBooking(\$bookingId: Int!) {
            startBooking(bookingId: \$bookingId) {
              booking{
                id
                title
                price
                pricingOption
                bookingType
                module
                moduleId
                moduleUser {
                  id
                  username
                }
                status
                address
                haveBrief
                deliverableType
                expectDigitalContent
                usageType {
                  id
                  name
                }
                usageLength {
                  id
                  name
                }
                brief
                briefFile
                briefLink
                startDate
                dateCreated
                lastUpdated
                deleted
                user{
                  id
                  username
                  profilePictureUrl
                }
                paymentSet {
                  id
                  amount
                  paymentRef
                  status
                }
              }
            }
          }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['startBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> bookieCompleteBooking({required int bookingId}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation bookieCompletedBooking(\$bookingId: Int!) {
            bookieCompleteBooking(bookingId: \$bookingId) {
              message
              booking{
                id
                title
                price
                pricingOption
                bookingType
                module
                moduleId
                moduleUser {
                  id
                  username
                }
                status
                address
                haveBrief
                deliverableType
                expectDigitalContent
                usageType {
                  id
                  name
                }
                usageLength {
                  id
                  name
                }
                brief
                briefFile
                briefLink
                startDate
                dateCreated
                lastUpdated
                deleted
                user{
                  id
                  username
                  profilePictureUrl
                }
                paymentSet {
                  id
                  amount
                  paymentRef
                  status
                }
              }
            }
          }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['bookieCompleteBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }

  Future<Either<CustomException, Map<String, dynamic>>> bookerCompleteBooking({required int bookingId}) async {
    try {
      final result = await vBaseServiceInstance.mutationQuery(mutationDocument: '''
          mutation bookerCompletedBooking(\$bookingId: Int!) {
            bookerCompleteBooking(bookingId: \$bookingId) {
              message
              booking{
                id
                title
                price
                pricingOption
                bookingType
                module
                moduleId
                moduleUser {
                  id
                  username
                }
                status
                address
                haveBrief
                deliverableType
                expectDigitalContent
                usageType {
                  id
                  name
                }
                usageLength {
                  id
                  name
                }
                brief
                briefFile
                briefLink
                startDate
                dateCreated
                lastUpdated
                deleted
                user{
                  id
                  username
                  profilePictureUrl
                }
                paymentSet {
                  id
                  amount
                  paymentRef
                  status
                }
              }
            }
          }
        ''', payload: {
        "bookingId": bookingId,
      });

      return result.fold((left) {
        return Left(left);
      }, (right) {
        return Right(right!['bookieCompleteBooking']);
      });
    } catch (e) {
      return Left(CustomException(e.toString()));
    }
  }
}

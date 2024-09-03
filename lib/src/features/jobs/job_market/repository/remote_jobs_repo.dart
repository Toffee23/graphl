
import 'package:either_option/either_option.dart';
import 'package:vmodel/src/app_locator.dart';
import 'package:vmodel/src/core/utils/exception_handler.dart';

class RemoteJobsRepository {
    RemoteJobsRepository._();
    static RemoteJobsRepository instance = RemoteJobsRepository._();

    Future<Either<CustomException,Map<String, dynamic>>>getRemoteJobs({
        int? dataCount})async{
        try{
            final result = await vBaseServiceInstance.getQuery(queryDocument: '''
query explore(\$dataCount: Int!){
    explore (dataCount:\$dataCount){
        id
        creator {
            firstName
            lastName
            email
        }
        jobTitle
        jobType
        priceValue
        shortDescription
        jobDelivery
    }
    
}''', payload: {
                'dataCount': dataCount,
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

    }

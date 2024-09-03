import 'package:vmodel/src/app_locator.dart';

class AccountTypeRepository {
  AccountTypeRepository._();
  static AccountTypeRepository instance = AccountTypeRepository._();
  Future<Map<String, dynamic>> getAccountType() async {
    final result = await vBaseServiceInstance.getOrdinaryQuery(
      queryDocument: '''
query getUserTypes {
  userTypes {
    enterprise {
      booker
      business
    }
    talent {
      model
      influencer
      digitalCreator
      photographer
      videographer
      petModel {
        cat
        dog
      }
      stylist
      chef
      cook
      baker
      eventPlanner
    }
  }
}
''',
      payload: {},
    );

    return result!;
  }
}

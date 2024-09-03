import 'dart:developer';
import 'package:vmodel/src/core/utils/logs.dart';

import '../../../app_locator.dart';

class ContactRepository {
  ContactRepository._();

  static ContactRepository instance = ContactRepository._();

  // Future<Either<CustomException, Map<String, dynamic>>> updateReview({required List<Map<String, dynamic>> contacts }) async {
  Future<Map<String, dynamic>> suggestedContacts({required List<Map<String, dynamic>> contacts}) async {
    try {
      final result = await vBaseServiceInstance.getQuery(queryDocument: '''
       query suggestedContacts (\$contacts: [ContactInput]!) {
          suggestedContacts(contacts: \$contacts) {
            registeredUsers {
                id
                username
                phone {
                  countryCode
                  number
                }
            }
            unregisteredContacts {
                name
                email
                phoneNumber
            }
          }
      }
        ''', payload: {
        "contacts": contacts,
      });

      return result.fold((left) {
        return {};
      }, (right) {
        final suggestedContacts = right?['suggestedContacts'];
        logger.f(suggestedContacts['registeredUsers']);
        return suggestedContacts;
      });
    } catch (e) {
      log("this is left message ${e}");

      return {};
    }
  }
}

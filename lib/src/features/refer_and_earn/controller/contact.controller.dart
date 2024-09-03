
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/refer_and_earn/model/contact.model.dart';
import 'package:vmodel/src/features/refer_and_earn/repository/contact.repo.dart';

final contactStateNotiferProvider = StateNotifierProvider<ContactStateNotifier, InviteContactModel>((ref) => ContactStateNotifier());

class ContactStateNotifier extends StateNotifier<InviteContactModel> {
  ContactStateNotifier() : super(InviteContactModel(registeredUsers: [], unregisteredContacts: []));

  final _repository = ContactRepository.instance;

  void init({required List<Map<String, dynamic>> contacts}) async {

    final response = await _repository.suggestedContacts(contacts: contacts);

    InviteContactModel contactModel = InviteContactModel.fromJson(response);

    state = contactModel;

  }
}

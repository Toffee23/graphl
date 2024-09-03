
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/jobs/job_market/views/search_field.dart';
import 'package:vmodel/src/features/refer_and_earn/controller/contact.controller.dart';
import 'package:vmodel/src/features/refer_and_earn/model/contact.model.dart';
import 'package:vmodel/src/features/refer_and_earn/views/invite_contact.dart';
import 'package:vmodel/src/features/refer_and_earn/widgets/action_button.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/shimmer/shimmerItem.dart';

import '../../../core/utils/shared.dart';
import '../../../shared/rend_paint/render_svg.dart';

class ReferAndEarnInviteContactsPage extends ConsumerStatefulWidget {
  const ReferAndEarnInviteContactsPage({super.key});

  @override
  ConsumerState<ReferAndEarnInviteContactsPage> createState() => _ReferAndEarnInviteContactsPageState();
}

class _ReferAndEarnInviteContactsPageState extends ConsumerState<ReferAndEarnInviteContactsPage> {
  bool showRecentSearches = false;
  bool _isLoading = true;
  bool _showPermissionDenied = false;
  final _isInvited = ValueNotifier(false);
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  List<Map<String, dynamic>> _contactsMap = [];

  FocusNode myFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchBarVisible = false;
  @override
  void initState() {
    super.initState();
    // _getContacts();
    checkPermissionStatus();
    // Permission.contacts.request();
  }

  Future<bool> checkPermissionStatus() async {
    PermissionStatus status = await Permission.contacts.status;
    // await _getContacts();
    if (status.isGranted) {
      //print("Permission isGranted.");
      await _getContacts();

      return true;
    } else {
      await Permission.contacts.request();

      _getContacts();

      return false;
    }
  }

  Future<void> _getContacts() async {
    setState(() => _isLoading = true);
    List<Contact> contacts = await ContactsService.getContacts();

    for (Contact contact in contacts) {
      _contactsMap.add({"contact": contact, "isInvited": false});
    }

    _contacts = _contactsMap;
    _filteredContacts = _contactsMap;
    _isLoading = false;
    //print(contacts.length);
    setState(() {});

    // List<Map<String, dynamic>> processedContacts = [...List.generate(contacts.length, (index) => {})];

    // Process the contacts into the required format for the GraphQL query
    List<Map<String, dynamic>> processedContacts = contacts.where((e) => e.phones != null && e.phones!.isNotEmpty).map((contact) {
      String? name = contact.displayName;
      String? email;
      String? phoneNumber;

      if (contact.emails != null && contact.emails!.isNotEmpty) {
        email = contact.emails!.first.value;
      }

      if (contact.phones != null && contact.phones!.isNotEmpty) {
        phoneNumber = contact.phones!.first.value!.replaceAll(' ', '');
      }

      return {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
      };
    }).toList();

    ref.read(contactStateNotiferProvider.notifier).init(contacts: processedContacts);
  }

  void _searchContacts(String query) {
    setState(() {
      _filteredContacts = _contactsMap.where((contact) {
        return contact['contact'].displayName?.toLowerCase().contains(query.toLowerCase()) ?? false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).iconTheme.color?.withOpacity(0.5);

    InviteContactModel processedContact = ref.watch(contactStateNotiferProvider);

    print(processedContact.registeredUsers);
    print(processedContact.unregisteredContacts);

    return Scaffold(
        appBar: VWidgetsAppBar(
          leadingIcon: VWidgetsBackButton(),
          appbarTitle: "Invite contacts",
          trailingIcon: [
            Flexible(
              child: IconButton(
                onPressed: () {
                  _isSearchBarVisible = !_isSearchBarVisible;
                  setState(() {});
                },
                icon: RenderSvg(
                  color: _isSearchBarVisible ? null : inactiveColor,
                  svgPath: VIcons.searchIcon,
                  svgHeight: 24,
                  svgWidth: 24,
                ),
              ),
            ),
          ],
        ),
        body: _showPermissionDenied
            ? Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings,
                    ),
                    addVerticalSpacing(20),
                    Text(
                      "Go to your setting and allow access to contact for VModel",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(children: [
                  if (_isSearchBarVisible)
                    SearchTextFieldWidget(
                      hintText: "Search...",
                      controller: _searchController,
                      onChanged: _searchContacts,
                      //     onPressed: () {
                      //       searchController.clear();
                      //     },
                      //     icon: const RenderSvg(
                      //       svgPath: VIcons.roundedCloseIcon,
                      //       svgHeight: 20,
                      //       svgWidth: 20,
                      //     )), // suffixIcon: IconButton(
                      onCancel: () {
                        _isSearchBarVisible = false;
                        setState(() {});
                      },
                    ),
                  Expanded(
                    child: !_isLoading
                        ? _filteredContacts.isNotEmpty
                            ? ListView.separated(
                                itemCount: _filteredContacts.length,
                                separatorBuilder: (context, index) => Divider(
                                      color: Theme.of(context).dividerColor,
                                      height: 1,
                                    ),
                                itemBuilder: (context, index) {
                                  Map<String, dynamic>? contact = _filteredContacts[index];
                                  List<Item>? phones = _contacts[index]['contact'].phones!.toList();
                                  String phoneNumbers = phones!.isNotEmpty ? phones[0].value ?? "" : "";

                                  return ListTile(
                                    onTap: () {
                                      navigateToRoute(context, ReferAndEarnInviteContactPage(contact: contact['contact']));
                                    },
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${contact['contact'].displayName ?? phoneNumbers}",
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                )),
                                        Text(phoneNumbers, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                    trailing: ReferAndEarnActionButton(
                                        title: processedContact.registeredUsers!.map((element) => element.phone!.number == _filteredContacts[index]['contact'].phones[0].value).toList().isNotEmpty &&
                                                processedContact.registeredUsers!.map((element) => element.phone!.number == _filteredContacts[index]['contact'].phones[0].value).toList().first
                                            ? 'View Profile'
                                            : contact['isInvited']
                                                ? 'Invited'
                                                : 'Invite',
                                        onPressed: () {
                                          if (processedContact.registeredUsers!.map((element) => element.phone!.number == _filteredContacts[index]['contact'].phones[0].value).toList().first) {
                                            RegisteredUser matchingContact =
                                                processedContact.registeredUsers!.where((element) => element.phone!.number == _filteredContacts[index]['contact'].phones[0].value).toList().first;
                                            context.push('${Routes.otherProfileRouter.split("/:").first}/${matchingContact.username}');
                                            return;
                                          }

                                          VMHapticsFeedback.lightImpact();
                                          for (int x = 0; x < _filteredContacts.length; x++) {
                                            if (x == index) {
                                              _filteredContacts[index]['isInvited'] = !_filteredContacts[index]['isInvited'];
                                              setState(() {});
                                            }
                                          }
                                        }),
                                  );
                                })
                            : Center(
                                child: Text("No contact found", style: Theme.of(context).textTheme.bodyLarge),
                              )
                        : shimmerItem(numOfItem: 10, context: context),
                  )
                ]),
              )));
  }
}

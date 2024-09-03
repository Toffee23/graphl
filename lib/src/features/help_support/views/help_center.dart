import 'package:go_router/go_router.dart';
import 'package:vmodel/src/res/assets/app_asset.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../shared/appbar/appbar.dart';

/// A stateless widget that contains the help center
class HelpCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Custom AppBar for help center page
      appBar: VWidgetsAppBar(
        appbarTitle: "Help Center",
        style: Theme.of(context)
            .textTheme
            .displayLarge!
            .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
        leadingIcon: VWidgetsBackButton(),
      ),

      /// Floating Action Button for additional actions
      floatingActionButton: GestureDetector(
        onTap: () {},
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color.fromRGBO(83, 59, 56, 1),
          ),
          child: Center(
            child: Icon(Icons.message, color: Colors.white),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          /// SliverAppBar to create a floating search bar effect
          SliverAppBar(
            floating: true,
            pinned: true,
            snap: false,
            expandedHeight: 10.0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container( decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15)
          ),child: _buildSearchField(context)),
            ),
          ),

          /// SliverList to display the main content of the page
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(25),
                      Image.asset(VmodelAssets2.helpCenter1, fit: BoxFit.fill),
                      addVerticalSpacing(18),
                      _buildInfoContainer(
                          context,
                          Icon(Icons.lock_outline_rounded),
                          "Protect your account", [
                        _buildListTile(context, "About blocked accounts"),
                        _buildListTile(context, "Changing your location"),
                        _buildListTile(
                            context, "Unable to change your username"),
                        _buildListTile(context, "Unable to change your DOB"),
                        _buildListTile(context, "Adding your email address",
                            isLast: true),
                      ]),
                      addVerticalSpacing(16),
                      _buildInfoContainer(
                          context,
                          Icon(Icons.phone_android_outlined),
                          "Life on VModel", [
                        _buildListTile(context, "How to create post"),
                        _buildListTile(context, "How to create jobs"),
                        _buildListTile(context, "How to create account"),
                        _buildListTile(context, "How to create services"),
                        _buildListTile(context, "Adding your email address",
                            isLast: true),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a container with a header and a list of clickable items
  Widget _buildInfoContainer(
      BuildContext context, Widget icon, String title, List<Widget> children) {
    return Container(
      height: 294,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).buttonTheme.colorScheme!.secondary),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 35,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  icon,
                  addHorizontalSpacing(20),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          fontSize: 16,
                          color: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.color
                              ?.withOpacity(1),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          ...children,
        ],
      ),
    );
  }

  /// Builds a clickable list tile with a title
  Widget _buildListTile(BuildContext context, String title,
      {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/popular_faqs_page');
          },
          child: SizedBox(
            height: 33,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.color
                          ?.withOpacity(1),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
        if (!isLast) Divider()
      ],
    );
  }

  /// Builds the search field with autocomplete functionality
  Widget _buildSearchField(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return Container(
          padding: EdgeInsets.all(8),
          child: TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: VmodelColors.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search_outlined, color: VmodelColors.text),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide:
                    BorderSide(color: VmodelColors.text.withOpacity(0.15)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide:
                    BorderSide(color: VmodelColors.text.withOpacity(0.15)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide:
                    BorderSide(color: VmodelColors.text.withOpacity(0.15)),
              ),
              hintStyle: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: VmodelColors.text),
              hintText: "Search...",
              constraints: const BoxConstraints(maxHeight: 35),
              contentPadding: const EdgeInsets.all(8),
            ),
          ),
        );
      },
    optionsViewBuilder: (context, onSelected, options) {
        return Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.topCenter,
          
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: SizedBox(
                height: options.length * 65,
                child: ListView.separated( // Use ListView.separated for dividers
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return ListTile(
                      title: Text(option),
                      onTap: () {
                        onSelected(option);
                        getActionForOption(option, context)();
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Divider(
                       
                        height: 0.5, // No extra height between items
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      onSelected: (String selection) {
        print('You just selected $selection');
      },
    );
  }

  /// List of autocomplete options
  final List<String> options = [
    "About blocked accounts",
    "Changing your location",
    "Unable to change your username",
    "Unable to change your DOB",
    "Adding your email address",
    "How to create post",
    "How to create jobs"
  ];

  /// Defines the action for each autocomplete option
  void Function() getActionForOption(String option, BuildContext context) {
    switch (option) {
      case 'About blocked accounts':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'Changing your location':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'Unable to change your username':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'Unable to change your DOB':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'Adding your email address':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'How to create post':
        return () {
          context.push('/popular_faqs_page');
        };
      case 'How to create jobs':
        return () {
          context.push('/popular_faqs_page');
        };
      default:
        return () {
          print("Selected: $option");
        };
    }
  }
}

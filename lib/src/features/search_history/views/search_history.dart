import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class SearchHistory extends ConsumerStatefulWidget {
  static const title = '';
  static const route = '/search_history';
  const SearchHistory({super.key});

  @override
  ConsumerState<SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends ConsumerState<SearchHistory> {
  final _searchHistoryController = TextEditingController();
  final _fontSize = 15.0;
  final _searchHistory = <Map<String, String>>[
    {'search': "God'sgift Uko", 'datetime': '2:00AM'},
    {'search': "God'sgift Uko", 'datetime': '2:00AM'},
    {'search': "God'sgift Uko", 'datetime': '2:00AM'},
    {'search': "God'sgift Uko", 'datetime': '2:00AM'},
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.1, color: Colors.black),
                ),
              ),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 12,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: !context.isDarkMode ? Colors.black : null,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 3,
                            child: TextField(
                              cursorColor:
                                  !context.isDarkMode ? null : Colors.white,
                              decoration: InputDecoration(
                                  hintText: 'Search',
                                  enabled: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false),
                            ) //Replace with your child widget
                            ),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          Text(
                            '|',
                            style: TextStyle(
                                color:
                                    !context.isDarkMode ? null : Colors.grey),
                          ),
                          TextButton.icon(
                              label: Text('Cancel',
                                  style: TextStyle(
                                      fontSize: _fontSize,
                                      color: !context.isDarkMode
                                          ? null
                                          : Colors.white)),
                              // icon: Icon(Icons.dehaze),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ) //Replace with your child widget
                      ),
                ],
              )),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 25,
                  child: Text(
                    'Search History',
                    style: TextStyle(
                        fontSize: _fontSize,
                        color:
                            !context.isDarkMode ? Colors.grey : Colors.white),
                  ), //Replace with your child widget
                ),
                Expanded(
                  flex: 3,
                  child: Icon(
                    Icons.delete_outline,
                    color: !context.isDarkMode ? Colors.grey[400] : null,
                  ), //Replace with your child widget
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _searchHistory.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.1, color: Colors.black),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.search,
                          color: !context.isDarkMode ? Colors.black : null,
                        ),
                        addHorizontalSpacing(10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _searchHistory[index]['search']!,
                              style: TextStyle(fontSize: _fontSize),
                            ),
                            addVerticalSpacing(10),
                            Text(
                              _searchHistory[index]['datetime']!,
                              style: TextStyle(
                                  fontSize: _fontSize, color: Colors.grey),
                            ),
                            addVerticalSpacing(10),
                          ],
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      )),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/models/app_user.dart';
import 'package:vmodel/src/features/settings/widgets/cupertino_switch_card.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';

class FavoriteHashtags extends ConsumerStatefulWidget {
  static const title = 'Favorite Hashtags';
  static const route = '/favorite_hashtags';
  const FavoriteHashtags({super.key});

  @override
  ConsumerState<FavoriteHashtags> createState() => _FavoriteHashtagsState();
}

class _FavoriteHashtagsState extends ConsumerState<FavoriteHashtags> {
  final _fontSize = 15.0;
  final _favoritePosts = <Map<String, String>>[
    {'hashtag': "Tattoo", 'stats': '37.9k'},
    {'hashtag': "naildesign", 'stats': '10.9k'},
    {'hashtag': "nailsnailsnails", 'stats': '5.9k'},
    {'hashtag': "Tattooed", 'stats': '4.9k'},
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
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue[400],
                            borderRadius: BorderRadius.circular(50.0),
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://img.freepik.com/free-psd/3d-illustration-human-avatar-profile_23-2150671122.jpg?size=338&ext=jpg&ga=GA1.1.2008272138.1723334400&semt=ais_hybrid'), // URL to your network image
                              fit: BoxFit.cover, // Cover the entire container
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 3,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? null
                                    : VmodelColors.lightGreyColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: !context.isDarkMode
                                        ? Colors.black
                                        : null,
                                    size: 20,
                                  ),
                                  // addHorizontalSpacing(30),
                                  Expanded(
                                    flex: 10,
                                    child: TextField(
                                      cursorColor: !context.isDarkMode
                                          ? null
                                          : Colors.white,
                                      decoration: InputDecoration(
                                          hintText: 'Search',
                                          enabled: true,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          filled: false),
                                    ),
                                  ),
                                ],
                              ),
                            ) //Replace with your child widget
                            ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                      label: Text('Cancel',
                          style: TextStyle(
                              fontSize: _fontSize,
                              color:
                                  !context.isDarkMode ? null : Colors.white)),
                      // icon: Icon(Icons.dehaze),
                      onPressed: () {
                        Navigator.pop(context);
                      })
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
                Text(
                  'Favorite hashtags',
                  style: TextStyle(
                      fontSize: _fontSize, fontWeight: FontWeight.w600),
                ),
                Icon(
                  Icons.star,
                  color: VmodelColors.starColor,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _favoritePosts.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "#${_favoritePosts[index]['hashtag']!}",
                                  style: TextStyle(fontSize: _fontSize),
                                ),
                                addVerticalSpacing(10),
                                Text(
                                  "${_favoritePosts[index]['stats']!} posts",
                                  style: TextStyle(
                                      fontSize: _fontSize, color: Colors.grey),
                                ),
                              
                                addVerticalSpacing(10),
                               
                              ],
                            ),
                            Icon(
                              Icons.delete_outline,
                              color: !context.isDarkMode ? Colors.grey[400] : null,
                            ),
                          ],
                        ),
                      ),
                         Divider(),
                    ],
                  );
                }),
          )
        ],
      )),
    );
  }
}

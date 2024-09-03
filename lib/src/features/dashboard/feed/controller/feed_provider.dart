import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/network/websocket.dart';

final isPictureViewProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});
final inContentView = StateProvider<bool>((ref) {
  return false;
});
final inContentScreen = StateProvider<bool>((ref) {
  return false;
});
final inLiveClass = StateProvider.autoDispose<bool>((ref) {
  return false;
});
final playVideoProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final newFeedAvaialble = StateProvider<List<dynamic>>((ref) => []);

final feedProvider = ChangeNotifierProvider((ref) {
  return FeedProvider();
});

final feedWS = Provider((ref) {
  final wsFeed = WSFeed();

  return wsFeed.listen();
});

final class FeedProvider extends ChangeNotifier {
  bool isShare = true;
  void isShared() {
    if (isShare) {
      isShare = false;
      notifyListeners();
    } else {
      isShare = true;
      notifyListeners();
    }
  }

  bool isLike = false;
  void isLiked() {
    isLike = !isLike;
    notifyListeners();
    // if (isLike) {
    //   isLike = false;
    //   notifyListeners();
    // }
    // else {
    //   isLike = true;
    //
    // }
  }

  bool isSave = false;
  void isSaved() {
    isSave = !isSave;
    notifyListeners();
  }

  bool isFeed = true;
  void isFeedPage({bool isFeedOnly = false, bool isNavigatoToDiscover = false}) {
    if (isNavigatoToDiscover) {
      // //print('^^^^^^^^^^^^^ First if');
      isFeed = false;
      notifyListeners();
      return;
    }
    if (isFeedOnly) {
      // //print('^^^^^^^^^^^^^ if 2');
      isFeed = true;
      notifyListeners();
      return;
    }
    if (isFeed) {
      // //print('^^^^^^^^^^^^^ if 3');
      isFeed = false;
      notifyListeners();
    } else {
      // //print('^^^^^^^^^^^^^ else');
      isFeed = true;
      notifyListeners();
    }
  }

  void isVideoScreen() {
    isFeed = false;
    notifyListeners();
  }

  // For the usage of Gallery Feed View Page
  // bool isPictureView = false;
  // void isPictureViewState() {
  //   isPictureView = !isPictureView;
  //   notifyListeners();
  // }

//Api call should not be in a controller
  //get feed stream

//   Future<Map<String, dynamic>?> getAllFeedPostsssss() async {
//     try {
//       final result =
//           await vBaseServiceInstance.getOrdinaryQuery(queryDocument: '''
// query getposts{
//   posts{
//     data{
//       photos{
//         data{
//           itemLink
//           description
//           postSet{
//             data{
//               postType
//             }
//           }
//         }
//       },
//       postType
//       videos{
//         data{
//           id
//           itemLink

//         }
//       }
//       audios{
//         data{
//           id
//           itemLink
//         }
//       }
//       album{
//         name
//       },
//       postType
//       id
//     }
//   }
// }

// ''', payload: {});

//       return result;
//     } catch (e) {
//       //print(e);
//     }
//     return null;
//   }
}

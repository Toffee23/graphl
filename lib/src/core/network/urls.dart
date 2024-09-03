import 'package:flutter_dotenv/flutter_dotenv.dart';

class VUrls {
  static bool isLive = false;

  static String baseUrl =
      isLive == true ? "www.google.com" : dotenv.env['API_URL'].toString();

  static String imageBaseUrl =
      isLive == true ? "www.google.com" : dotenv.env['IMAGE_URL'].toString();

  static String postMediaUploadUrl = isLive == true
      ? dotenv.env['LIVE_UPLOAD_URL'].toString()
      : dotenv.env['POST_UPLOAD_URL'].toString();

  static String videoUploadUrl = dotenv.env['VIDEO_UPLOAD_URL'].toString();

  static String postVideoMediaUploadUrl = isLive == true
      ? "www.google.com"
      : dotenv.env['POST_UPLOAD_VIDEO_URL'].toString();

  static String webSocketUrl =
      isLive == true ? "www.google.com" : dotenv.env['SOCKET_URL'].toString();

  static String webSocketBaseUrl = isLive == true
      ? "www.google.com"
      : dotenv.env['SOCKET_URL_BASE'].toString();

  static String serviceBannerUploadUrl = isLive == true
      ? "www.google.com"
      : dotenv.env['SERVICE_BANNER_UPLOAD_URL'].toString();

  static String profilePictureUploadUrl = isLive == true
      ? "www.google.com"
      : dotenv.env['PROFILE_UPLOAD_URL'].toString();

  static String postThumbnailOnlyUrl = isLive == true
      ? "www.google.com"
      : dotenv.env['POST_THUMBNAIL_UPLOAD_URL'].toString();

  static String mapsApiKey = dotenv.env['GMAP_KEY'].toString();

  static const String faqUrl = "https://www.vmodelapp.com/help-center";
  static const String aboutUrl = "https://www.vmodelapp.com/about";
  static const String spotifyUrl =
      "https://podcasters.spotify.com/pod/show/vmodel";

 
  static const String privacyPolicyUrl = "https://www.vmodel.app/?page_id=1926";

  static bool shouldLoadSomefeatures = false;
}

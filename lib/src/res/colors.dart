import 'package:flutter/material.dart';
import 'package:vmodel/src/core/utils/extensions/hex_color.dart';

class VmodelColors {
  VmodelColors._();
  static const Color pinkColor = Colors.green;
  static const Color darkPrimaryColorWhite = Color(0xFFF0F3F6);
  static const Color primaryColor = Color(0xFF543B3A);
  static const Color bottomNavIndicatiorColor = Color(0xFFFD4A40);
  static const Color appBarBackgroundColor = Color(0xFFFFFFFF);
  static const Color darkIconColor = Color(0xFFFFFFFF);
  static const Color darkScaffoldBackround = Color(0xFF222222);
  static const Color blackScaffoldBackround = Colors.black;
  static const Color darkButtonColor = Color(0xFF37474F); //background: #37474F;
  static Color blackUpdated = '0C0F12'.fromHex;
  static Color blackButtonColorUpdated = '1A4577'.fromHex;

  static const Color darkSecondaryButtonColor = Color(0xFF82909D);
  static const Color appBarShadowColor = Color(0xFFEEEEEE);
  static const Color divideColor = Color(0xFFDADBDA);
  static const Color yellowTextColor = Color(0xFFFFE600);
  static const Color heartIconColor = Color.fromRGBO(255, 68, 59, 1);
  static const Color badgeIconColor = Color.fromRGBO(0, 191, 255, 0.8);
  static const Color disabledButonColor = Color(0xFF543B3B);
  static const Color greyColorButton = Color(0xFFEFEFEF);
  static const Color bottomNavbarBackgroundColorDarkTheme = Color(0xFF82909D);
  static Color mainColor = const Color(0xFF543b3a);
  static Color background = const Color(0xFFffffff);
  static Color borderColor = const Color(0xffDEDEDE);
  static Color buttonColor = const Color(0xff543B3B);
  static Color buttonBgColor = const Color(0xffEFEFEF);
  static Color white = const Color(0xffffffff);
  static Color hintColor = const Color(0xff543B3A);
  static Color error = const Color(0xffE05050);
  static Color text = const Color(0xff543B3A);
  static Color unselectedText = const Color(0xff211D1D);
  static Color text2 = const Color(0xff3897F0);
  static Color text3 = const Color(0xff969090);
  static Color text4 = const Color(0xffD8D8D8);
  static Color jobDetailGrey = const Color(0xffD9D9D9);
  static Color blackColor = Colors.black;
  static Color searchOutlineColor = const Color(0xffB4B4B4);
  static Color ligtenedText = const Color(0x88503C3B);
  static Color dividerColor = const Color(0xFFDEDEDE);
  static Color lightText = const Color(0xFFAAAAAA);
  static Color blueTextColor = const Color(0xff0078FF);
  static Color boldGreyText = const Color(0xFF666666);
  static Color switchOffColor = const Color(0xFFE9E9EA);
  static Color greyDeepText = const Color(0xFF3E3E3E);
  static Color contractBackgroundColor = const Color(0xffF6F6F6);
  static const MaterialColor vModelprimarySwatch = MaterialColor(
    0xff503C3B, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: primaryColor, //10%
      100: primaryColor, //20%
      200: primaryColor, //30%
      300: primaryColor, //40%
      400: primaryColor, //50%
      500: primaryColor, //60%
      600: primaryColor, //70%
      700: primaryColor, //80%
      800: primaryColor, //90%
      900: primaryColor, //100%
    },
  );
  static Color shadowColor = const Color(0xFFE3E8EF);
  static Color grey = Colors.grey;
  static Color greyColor = const Color(0xFF9F9C9C);
  static Color greyLightColor = const Color(0xFFD9D9D9);
  static Color darkGreyColor = const Color(0xFF696464);
  static Color textColor = const Color(0xFF211D1D);
  static Color black = const Color(0xff1C1B1F);

  static Color surfaceVariantLight = Color(0xFFD9D9D9);
  static Color onSurfaceVariantLight = Color(0xFFF0F1F5);

  static const Color textDarkBlue = Color(0xFF618293);

  static const Color defaultGradientBegin = Color(0xFFDC3535);
  static const Color defaultGradientEnd = Color(0xFF3140C9);
  static const Color defaultChartGradientBegin = Color(0xFF5C3989);
  static const Color starColor = Color(0xfff1bd58);
  //profile
  // background: #37474F; //main blue buttons
  // static const Color textDarkBlue = Color(0x82909D); //light blue button
  // background: #618293; // text blue ('Coupons')
  // background: #82909D; // tab unselected blue
  // background: #82909D; //bottom nav top border blue

  //Black theme colors
  static const Color blackButtonColor = Color(0xFF503C3B);

  static const Color blueColor9D = Color(0xFF82909D);
  static const Color darkPrimaryColor = Color(0xFF37474F);
  static const Color darkOnSurfaceColor = Color(0xFFD7D7D7);
  static const Color darkOnPrimaryColor = Color(0xFFDDDDDD);

  static Color blackCardColor = '18181A'.fromHex; //Color(0xFF161616);
  static const Color darkThemeCardColor = Color(0xFF303030);
  static Color notificationDarkModeOverlayColor = '161616'.fromHex;
  // static const Color darkOnPrimaryColor = Color.fromARGB(255, 255, 121, 121);

  //Discover
  // background: #37474F; // top buttons outer
  // background: #FFFFFF2; 70% // top buttons inner
  // background: #37474F; // list item
  // background: #969090; //Less bright text

  //Bottom sheet
  // background: #82909D; //outer bottom sheet
  // border: 1.5px solid #292D32 // middle bottom sheet
  // background: #37474F80; //item bottom sheet (coupon)

  //booking
  // background: #37474FCC; 80% transparent // Date selected blue
  // border: 1.5px solid #618293F2; 95% transparent //input outline
  // border: 1.5px solid #37474FF2; 95% transparent //input outline location
  // border: 1px solid #618293CC; 80% transparent // input outline time selection dropdown e.g 3:00 PM
  // border: 2px solid #618293F2; 95% transparent // job hours calculated outline
  // background: #618293; // Continue button

// background: linear-gradient(269.88deg, #E82020 0.72%, rgba(232, 32, 32, 0.61) 33.45%, rgba(34, 232, 208, 0.66) 99.9%);

  static const Color gr0 = Color.fromARGB(255, 232, 32, 32);
  static const Color gr1 = Color.fromARGB(156, 232, 32, 32);
  static const Color gr2 = Color.fromARGB(168, 34, 232, 208);
  static const Color navbarColor = Color.fromARGB(255, 251, 250, 250);
  static const Color navbarDarkColor = Color.fromARGB(155, 16, 23, 28);

  static Color lightBgColor = background; //'efefef'.fromHex;
  static Color portfolioIcon = '75DDDD'.fromHex;
  static Color accountsIcon = '247BA0'.fromHex;
  static Color paymentIcon = '266DD3'.fromHex;
  static Color appearanceIcon = '0EAD69'.fromHex;
  static Color privacyIcon = '618B4A'.fromHex;
  static Color notificationIcon = '598392'.fromHex;
  static Color verificationIcon = '247BA0'.fromHex;
  static Color feedIcon = '4897B5'.fromHex;
  static Color personalityIcon = 'AFFC41'.fromHex;
  static Color galleriesIcon = '0EAD69'.fromHex;
  static Color securityIcon = '00C49A'.fromHex;

  static Color modalBgColorBlackMode = '262B31'.fromHex;

  //Marketplace
  static const Color serviceColor = Color(0xFF25B88E);
  static const Color serviceLightColor = Color(0xFF45C39E);
  static const Color couponColor = Color(0xFFF38E3C);
  static const Color couponLightColor = Color(0xFFF39F59);
  static const Color jobColor = Color(0xFF3D79C2);
  static const Color jobLightColor = Color(0xFF78A0D0);
  static const Color requestColor = Color(0xFF784AF5);
  static const Color requestLightColor = Color(0xFF8B65F8);

  static Color darkAmber = '96890f'.fromHex;
  static Color darkBrown = '262525'.fromHex;

  static Color lightGreyColor = '#f7f9fb'.fromHex;
} // you can defi

final topicColor = [
  '3b79c2'.fromHex,
  '4a3652'.fromHex,
  'cb3e34'.fromHex,
  '972c56'.fromHex,
  '3b79c2'.fromHex,
  '4a3652'.fromHex,
  'cb3e34'.fromHex,
  '972c56'.fromHex,
  '3b79c2'.fromHex,
  '4a3652'.fromHex,
  'cb3e34'.fromHex,
  '972c56'.fromHex,
  '3b79c2'.fromHex,
  '4a3652'.fromHex,
  'cb3e34'.fromHex,
  '972c56'.fromHex,
  '3b79c2'.fromHex,
  '4a3652'.fromHex,
  'cb3e34'.fromHex,
  '972c56'.fromHex,
];
final topicsColor = [
  '972c56'.fromHex,
  'cb3e34'.fromHex,
  '4a3652'.fromHex,
  '3b79c2'.fromHex,
  '972c56'.fromHex,
  '007b8b'.fromHex,
  '2a547a'.fromHex,
  '972c56'.fromHex,
  'cb3e34'.fromHex,
  '4a3652'.fromHex,
  '3b79c2'.fromHex,
  '972c56'.fromHex,
  '007b8b'.fromHex,
  '2a547a'.fromHex,
  '972c56'.fromHex,
  'cb3e34'.fromHex,
  '4a3652'.fromHex,
  '3b79c2'.fromHex,
  '972c56'.fromHex,
  '007b8b'.fromHex,
  '2a547a'.fromHex,
];

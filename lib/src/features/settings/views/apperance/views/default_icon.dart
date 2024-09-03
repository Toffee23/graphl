import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../res/icons.dart';
import '../widgets/default_icon_tile.dart';

class DefaultIconPage extends StatefulWidget {
  const DefaultIconPage({super.key});

  @override
  State<DefaultIconPage> createState() => _DefaultIconPageState();
}

class _DefaultIconPageState extends State<DefaultIconPage> {
  bool isSelected = false;
  int _currentlySelectedIndex = 0;

  List iconNames = <String>['brown', 'butter', 'punk', 'graffiti'];

  String dropDownCurrencyTypeValue = "Classic (White, brown)";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    int selectedIndex = await getDefaultIconPosition();
    _currentlySelectedIndex = selectedIndex;
    setState(() {
      selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VWidgetsAppBar(
        leadingIcon: VWidgetsBackButton(),
        appbarTitle: "Default Icon",
      ),
      body: Padding(
        padding: const VWidgetsPagePadding.horizontalSymmetric(18),
        child: SingleChildScrollView(
          child: Column(
            children: [
              addVerticalSpacing(20),
              //! Currently only one theme is present that's why the isSelected bool is always true
              VWidgetsAppearanceDefaultIconTile(
                title: "Brown",
                isSelected: _currentlySelectedIndex == 0,
                svgIconAsset: VIcons.defaultIconBrown,
                onTap: () {
                  setState(() {
                    changeAppIcon(0);
                  });
                },
              ),
              VWidgetsAppearanceDefaultIconTile(
                title: "Butter",
                isSelected: _currentlySelectedIndex == 1,
                svgIconAsset: VIcons.defaultIconButter,
                onTap: () {
                  setState(() {
                    changeAppIcon(1);
                  });
                },
              ),
              VWidgetsAppearanceDefaultIconTile(
                title: "CyberPunk",
                isSelected: _currentlySelectedIndex == 2,
                svgIconAsset: VIcons.defaultIconCyberpunk,
                onTap: () {
                  setState(() {
                    changeAppIcon(2);
                  });
                },
              ),
              VWidgetsAppearanceDefaultIconTile(
                title: "Graffiti",
                isSelected: _currentlySelectedIndex == 3,
                svgIconAsset: VIcons.defaultIconGraffiti,
                onTap: () {
                  setState(() {
                    changeAppIcon(3);
                  });
                },
              ),
              //  const VWidgetsThemes(title: "Modern (White-Brown)"),
            ],
          ),
        ),
      ),
    );
  }

  changeAppIcon(int index) async {
    try {
      print("index: $index");
      print("iconName: ${iconNames[index]}");
      final bool isSupported = await FlutterDynamicIcon.supportsAlternateIcons;
      _currentlySelectedIndex = index;
      if (isSupported) {
        await FlutterDynamicIcon.setAlternateIconName(iconNames[index]);
        await saveDefaultIconPosition(index);
        debugPrint("App icon change successful");
        return;
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
    debugPrint("Failed to change app icon ");
  }
}

// Save Default Icon Position
Future<void> saveDefaultIconPosition(int position) async {
  const key = 'default_icon';
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setInt(key, position);
}

// Get Default Icon Position
Future<int> getDefaultIconPosition() async {
  const key = 'default_icon';
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int? position = await preferences.getInt(key);
  return position ?? 0;
}

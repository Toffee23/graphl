import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_item.dart';
import 'package:vmodel/src/shared/tabbar/model/tab_style.dart';
import 'package:vmodel/src/vmodel.dart';

class VTabBarComponent extends StatelessWidget {
  const VTabBarComponent({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.style,
  });

  final List<TabItem> tabs;
  final int currentIndex;
  final Function(int index) onTap;
  final TabStyle? style;

  @override
  Widget build(BuildContext context) {
    Color bgColor = context.isDarkMode ? VmodelColors.white : VmodelColors.vModelprimarySwatch;
    Color fgColor = context.isDarkMode ? VmodelColors.black : VmodelColors.white;
    Color borderColor = context.isDarkMode ? Colors.grey.withOpacity(0.3) : Colors.grey[200]!;

    return Row(
      children: List.generate(
        tabs.length,
        (index) {
          final tab = tabs[index];
          final isActive = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: style?.contentPadding ?? EdgeInsets.symmetric(vertical: 6, horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: style?.borderColor ?? borderColor),
                borderRadius: BorderRadius.circular(10),
                color: isActive ? bgColor : null,
              ),
              child: Text(tab.title, style: TextStyle(fontSize: 16, color: isActive ? fgColor : null)),
            ),
          );
        },
      ),
    );
  }
}

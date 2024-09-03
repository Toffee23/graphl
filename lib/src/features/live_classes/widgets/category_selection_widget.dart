import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../core/controller/discard_editing_controller.dart';
import '../../../core/utils/costants.dart';
import '../../settings/views/booking_settings/widgets/category_modal.dart';

class CategorySelection extends ConsumerStatefulWidget {
  final void Function(List<String>)? onSelected;
  const CategorySelection({
    super.key,
    this.onSelected,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategorySelectionState();
}

class _CategorySelectionState extends ConsumerState<CategorySelection> {
  List<String> selectedCategoryList = [];
  List<Map> categoryList = [];

  @override
  void initState() {
    super.initState();
    for (var data in VConstants.tempCategories) {
      categoryList.add({"item": data, "selected": false});
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (timelineFormWidgets.isEmpty)
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select categories",
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor.withOpacity(1),
                        ),
                  ),
                  addVerticalSpacing(10),
                  GestureDetector(
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isDismissible: true,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10))),
                        builder: (context) {
                          return Container(
                            child: CategoryModal(
                              categoryList: categoryList,
                              selectedCategoryList: selectedCategoryList,
                              onTap: () {
                                selectedCategoryList.clear();
                                for (var data in categoryList) {
                                  if (data['selected']) {
                                    selectedCategoryList.add(data['item']);
                                  }
                                }
                                //print('[discard******] updating category list');

                                ref.read(discardProvider.notifier).updateState(
                                    'category',
                                    newValue: selectedCategoryList);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                      widget.onSelected?.call(selectedCategoryList);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .buttonTheme
                            .colorScheme!
                            .secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Select up to 3"),
                          Icon(Icons.arrow_drop_down)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        addVerticalSpacing(10),
        if (selectedCategoryList.isNotEmpty)
          Container(
            height: 40,
            // padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: selectedCategoryList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedCategoryList[index],
                      ),
                      GestureDetector(
                        onTap: () {
                          for (var data in categoryList) {
                            if (data['item'] == selectedCategoryList[index]) {
                              data['selected'] = false;
                            }
                          }
                          selectedCategoryList.removeAt(index);
                          setState(() {});
                        },
                        child: Icon(
                          Icons.cancel,
                          size: 20,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

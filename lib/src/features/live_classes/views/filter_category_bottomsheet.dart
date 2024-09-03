import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/controller/discard_editing_controller.dart';
import '../../../core/utils/costants.dart';
import '../../../core/utils/validators_mixins.dart';
import '../../../res/gap.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/text_fields/primary_text_field.dart';
import '../../settings/views/booking_settings/widgets/category_modal.dart';

class FilterCategoryBottomSheet extends ConsumerStatefulWidget {
  final Function() onFilter;
  const FilterCategoryBottomSheet(this.onFilter, {Key? key}) : super(key: key);

  @override
  ConsumerState<FilterCategoryBottomSheet> createState() =>
      _FilterCategoryBottomSheetState();
}

class _FilterCategoryBottomSheetState
    extends ConsumerState<FilterCategoryBottomSheet> {
  List<String> selectedCategoryList = [];
  List<Map> categoryList = [];

  TextEditingController _minsEditingController = TextEditingController();
  TextEditingController _dateEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var data in VConstants.tempCategories) {
      categoryList.add({"item": data, "selected": false});
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Filter by',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          addVerticalSpacing(10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 1),
              child: Text(
                'Category',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          addVerticalSpacing(16),
          GestureDetector(
            onTap: () => showModalBottomSheet(
                context: context,
                isDismissible: true,
                useRootNavigator: true,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10))),
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

                        ref.read(filterCategoriesProvider.notifier).updateState(
                            'category',
                            newValue: selectedCategoryList);
                        setState(() {});
                      },
                    ),
                  );
                }),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).buttonTheme.colorScheme!.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Select"), Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
          addVerticalSpacing(16),
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
                      color:
                          Theme.of(context).buttonTheme.colorScheme!.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCategoryList[index],
                          style: TextStyle(color: Colors.black),
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
          addVerticalSpacing(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: VWidgetsPrimaryTextFieldWithTitle2(
                  minLines: 1,
                  // maxLines: 2,
                  isDense: true,
                  controller: _dateEditingController,
                  label: 'Date Range',
                  hintText: 'Jan 5 - Dec 25th',
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                  heightForErrorText: 0,
                  onChanged: (val) {
                    ref
                        .read(discardProvider.notifier)
                        .updateState('price', newValue: val);
                  },
                  validator: (value) =>
                      VValidatorsMixin.isNotEmpty(value, field: "Length"),
                ),
              ),
              addHorizontalSpacing(10),
              Flexible(
                child: VWidgetsPrimaryTextFieldWithTitle2(
                  minLines: 1,
                  // maxLines: 2,
                  isDense: true,
                  controller: _minsEditingController,
                  label: 'Mins',
                  hintText: '100 mins',
                  keyboardType: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                  heightForErrorText: 0,
                  onChanged: (val) {
                    ref
                        .read(discardProvider.notifier)
                        .updateState('price', newValue: val);
                  },
                  validator: (value) =>
                      VValidatorsMixin.isNotEmpty(value, field: "Mins"),
                ),
              ),
            ],
          ),
          addVerticalSpacing(10),
          VWidgetsPrimaryButton(
              // butttonWidth: double.infinity,
              showLoadingIndicator: false,
              buttonTitle: 'Filter',
              enableButton: true,
              onPressed: () {
                Navigator.of(context).pop(true);
              }),
        ],
      ),
    );
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vmodel/src/core/utils/extensions/strings.dart';

class DropDownSelectionWidget<T> extends StatelessWidget {
  final T? selectedItem;
  final String hintText;
  final List<T> items;
  final Function(T?)? onChanged;
  const DropDownSelectionWidget({
    super.key,
    required this.selectedItem,
    required this.items,
    this.onChanged,
    required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      dropdownButtonProps: DropdownButtonProps(
        iconSize: 32,
      ),
      popupProps: PopupProps.bottomSheet(
          showSelectedItems: true,
          showSearchBox: true,
          itemBuilder: (context, item, isSelected) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
              child: Text(
                item.toString(),
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            );
          },
          onDismissed: () {},
          // constraints:
          //     BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
          // listViewProps: ListViewProps(
          //     padding: EdgeInsets.only(
          //         bottom: MediaQuery.of(context).viewInsets.bottom)),
          searchFieldProps: TextFieldProps(
              cursorColor: Colors.white60,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
                suffixIcon: Icon(Icons.search, color: Colors.white60),
                fillColor: Colors.white10,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              padding: EdgeInsets.only(top: 14, right: 14, left: 14)),
          bottomSheetProps: BottomSheetProps(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            )),
          )
          // disabledItemFn: (String s) => s.startsWith('I'),
          ),
      onChanged: onChanged,
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          //labelText: "Menu mode",
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      selectedItem: selectedItem,
    );
  }
}

class AccountSelectionTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final void Function()? onTap;
  const AccountSelectionTextField({
    super.key,
    required this.hintText,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(
          Icons.arrow_drop_down,
        ),
        hintText: hintText.toType(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

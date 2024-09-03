import 'package:flutter/material.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar_title_text.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:go_router/go_router.dart';

class BookingSettings extends StatelessWidget {
  const BookingSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const VWidgetsAppBarTitleText(
          titleText: "Booking Setting",
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: const VWidgetsBackButton(),
        actions: [
          VWidgetsTextButton(
            text: 'Next',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              //Text("Price")
              ListTile(
                  onTap: () {
                    context.push('/BookingSettingsOptions');
                  },
                  leading: Text(
                    "Price",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: VmodelColors.buttonColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined)),
              ListTile(
                  onTap: () {},
                  leading: Text(
                    "Availability",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: VmodelColors.buttonColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined)),
              ListTile(
                  leading: Text(
                    "Calls",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: VmodelColors.buttonColor,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined))
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: vWidgetsInitialButton(() {}, "Done"),
          )
        ],
      ),
    );
  }
}

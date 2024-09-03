import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/core/utils/shared.dart';

import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/buttons/primary_button.dart';

class RestoreDeletedPostView extends ConsumerWidget {
  final String? postid;

  const RestoreDeletedPostView({Key? key, this.postid}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('$postid');
    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Deleted Posts",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network('https://images.unsplash.com/photo-1604514628550-37477afdf4e3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3327&q=80', fit: BoxFit.cover,),
              ),
            )),
            Padding(
              padding: EdgeInsets.all(15),
              child: VWidgetsPrimaryButton(
                butttonWidth: MediaQuery.sizeOf(context).width,
                showLoadingIndicator: false,
                onPressed: () async {
                  VMHapticsFeedback.lightImpact();
                },
                buttonTitle: 'Restore',
              ),
            )
          ],
        ),
      ),
    );
  }
}

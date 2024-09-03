import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/utils/shared.dart';
import '../../../shared/appbar/appbar.dart';

class BetaDashBoardWeb extends StatefulWidget {
  const BetaDashBoardWeb({super.key, required this.title, required this.url});

  final String title, url;

  @override
  State<BetaDashBoardWeb> createState() => _BetaDashBoardWebState();
}

class _BetaDashBoardWebState extends State<BetaDashBoardWeb> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(widget.url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  bool progress = false;

  void _reloadPage() async {
    setState(() => progress = true );    
    await Future.delayed(Duration(seconds: 2));
    _controller.reload();
    setState(() => progress = false );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),
        appbarTitle: widget.title,
        trailingIcon: [
          TextButton(
            onPressed: () {
              VMHapticsFeedback.lightImpact();
              _reloadPage();
            },
            child: Icon(Icons.refresh),
          )
        ],
      ),
      body:  progress ?           Center(
        child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
      ) :  Column(
        children: [
          Expanded(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}

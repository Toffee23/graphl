import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

class CoverSelector extends StatefulWidget {
  const CoverSelector({super.key, required this.file});

  final File file;

  @override
  State<CoverSelector> createState() => _CoverSelectorState();
}

class _CoverSelectorState extends State<CoverSelector> {
  final _slideValue = ValueNotifier<double>(0);

  late VideoPlayerController _controller;

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() async {
    _controller.dispose();
    _slideValue.dispose();
    super.dispose();
  }

  void captureImage() async {
    screenshotController.capture().then((Uint8List? image) async {
      if (image != null) {
        Navigator.of(context).pop(image);
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: captureImage,
            icon: Icon(
              Icons.save,
            ),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (!_controller.value.isInitialized) {
          return Center(
            child: CircularProgressIndicator.adaptive(
              backgroundColor: const Color.fromARGB(255, 18, 14, 14),
            ),
          );
        }
        return Column(
          children: [
            Text(
              'Choose how your video cover for others.',
              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Screenshot(
                  controller: screenshotController,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(
                      _controller,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: _coverSelection(),
            ),
          ],
        );
      }),
    );
  }

  Widget _coverSelection() {
    final duration = _controller.value.duration;

    return ValueListenableBuilder(
      valueListenable: _slideValue,
      builder: (context, slider, _) {
        return Slider.adaptive(
          value: slider,
          min: 0,
          max: duration.inMicroseconds.toDouble(),
          onChanged: (changedValue) {
            _slideValue.value = changedValue;
            _controller.seekTo(
              Duration(
                microseconds: changedValue.toInt(),
              ),
            );
          },
        );
      },
    );
  }
}

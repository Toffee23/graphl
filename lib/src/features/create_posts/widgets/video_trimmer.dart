import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 0),
    maxDuration: const Duration(seconds: 10000),
    trimStyle: TrimSliderStyle(iconColor: Colors.black, edgesSize: 20),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    // ExportService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
      // format: VideoExportFormat.gif,
      // commandBuilder: (config, videoPath, outputPath) {
      //   final List<String> filters = config.getExportFilters();
      //   filters.add('hflip'); // add horizontal flip

      //   return '-i $videoPath ${config.filtersCmd(filters)} -preset ultrafast $outputPath';
      // },
    );

    // await ExportService.runFFmpegCommand(
    //   await config.getExecuteConfig(),
    //   onProgress: (stats) {
    //     _exportingProgress.value = config.getFFmpegProgress(stats.getTime());
    //   },
    //   onError: (e, s) => _showErrorSnackBar("Error on export video :("),
    //   onCompleted: (file) {
    //     _isExporting.value = false;
    //     if (!mounted) return;
    //
    //     showDialog(
    //       context: context,
    //       builder: (_) => VideoResultPopup(video: file),
    //     );
    //   },
    // );
  }

  void _exportCover() async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      _showErrorSnackBar("Error on cover exportation initialization.");
      return;
    }

    // await ExportService.runFFmpegCommand(
    //   execute,
    //   onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
    //   onCompleted: (cover) {
    //     if (!mounted) return;
    //
    //     showDialog(
    //       context: context,
    //       builder: (_) => CoverResultPopup(cover: cover),
    //     );
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: _controller.initialized
          ? Column(
              children: [
                Text('Choose how your video appear for others.',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.sizeOf(context).height / 1.8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CropGridViewer.preview(controller: _controller),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _controller.video,
                      builder: (_, __) => AnimatedOpacity(
                        opacity: _controller.isPlaying ? 0 : 1,
                        duration: kThemeAnimationDuration,
                        child: GestureDetector(
                          onTap: _controller.video.play,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _trimSlider(),
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _isExporting,
                  builder: (_, bool export, Widget? child) => AnimatedSize(
                    duration: kThemeAnimationDuration,
                    child: export ? child : null,
                  ),
                  child: AlertDialog(
                    title: ValueListenableBuilder(
                      valueListenable: _exportingProgress,
                      builder: (_, double value, __) => Text(
                        "Exporting video ${(value * 100).ceil()}%",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotate unclockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  //   Navigator.push(
                  //   context,
                  //   MaterialPageRoute<void>(
                  //     builder: (context) => CropPage(controller: _controller),
                  //   ),
                  // );
                },
                icon: const Icon(Icons.crop),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: 'Open export menu',
                icon: const Icon(Icons.save),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: _exportCover,
                    child: const Text('Export cover'),
                  ),
                  PopupMenuItem(
                    onTap: _exportVideo,
                    child: const Text('Export video'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt())),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.white)),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(_controller.startTrim),
                  ),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 3),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            quantity: 0,
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

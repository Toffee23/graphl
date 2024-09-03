import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/haptics_controller.dart';
import 'package:vmodel/src/features/help_support/controllers/report_image_controller.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/models/banner_model.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/widgets/service_image_tile.dart';
import 'package:vmodel/src/res/colors.dart';

class ReportImageListView extends ConsumerStatefulWidget {
  const ReportImageListView({
    super.key,
    required this.fileImages,
    required this.addMoreImages,
  });
  final List<BannerModel> fileImages;
  final Function() addMoreImages;
  // List<String>? urlImages;

  @override
  ConsumerState<ReportImageListView> createState() => _ReportImageListViewState();
}

class _ReportImageListViewState extends ConsumerState<ReportImageListView> {
  List<BannerModel> _imageList = [];
  bool ignore = false;
  @override
  void initState() {
    for (var index = 0; index < widget.fileImages.length; index++)
      _imageList.add(
        widget.fileImages[index],
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Theme.of(context).buttonTheme.colorScheme!.secondary,
            // border: Border.all(
            //   color: Theme.of(context).buttonTheme.colorScheme!.secondary,
            //   width: 2,
            // ),
            borderRadius: BorderRadius.circular(10)),
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            for (int index = 0; index < widget.fileImages.length; index += 1) ...[
              if (widget.fileImages[index].isFile)
                SelectedServiceImage(
                  key: ValueKey(widget.fileImages[index]),
                  image: FileImage(widget.fileImages[index].file!),
                  onPressRemove: () {
                    ref.read(reportImagesProvider.notifier).removeImage(index);
                  },
                ),
              if (!widget.fileImages[index].isFile)
                SelectedServiceImage(
                  key: ValueKey(widget.fileImages[index]),
                  image: CachedNetworkImageProvider(widget.fileImages[index].bannerThumbnailUrl!),
                  onPressRemove: () {
                    ref.read(reportImagesProvider.notifier).removeImage(index);
                  },
                ),
            ],
            GestureDetector(
              key: ValueKey("gesture"),
              onLongPress: () {
                setState(() {
                  ignore = true;
                });
              },
              onLongPressEnd: (details) {
                setState(() {
                  ignore = false;
                });
              },
              child: IgnorePointer(
                ignoring: ignore,
                child: _addMoreImages(),
              ),
            ),
          ],
          proxyDecorator: (child, index, animation) {
            return Card(
              color: Colors.transparent,
              child: child,
            );
          },
          onReorderStart: (index) {
            // //print('[sio3] start $index');
            VMHapticsFeedback.lightImpact();
          },
          onReorder: (int oldIndex, int newIndex) {
            //print(newIndex);
            //print(oldIndex);

            VMHapticsFeedback.lightImpact();
            try {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final BannerModel item = widget.fileImages.removeAt(oldIndex);
                widget.fileImages.insert(newIndex, item);
              });
            } catch (e) {
              return;
            }
          },
        )

        // ReorderableList(
        //   shrinkWrap: true,
        //   scrollDirection: Axis.horizontal,
        //   itemCount: widget.fileImages.length + 1,
        //   itemBuilder: (context, index) {
        //     if (index == widget.fileImages.length) {
        //       return _addMoreImages();
        //     }
        //     final item = widget.fileImages[index];
        //     if (item.isFile)
        //       return SelectedServiceImage(
        //         key: ValueKey(item),
        //         image: FileImage(item.file!),
        //         onPressRemove: () {
        //           ref.read(serviceImagesProvider.notifier).removeImage(index);
        //         },
        //       );
        //     return SelectedServiceImage(
        //       key: ValueKey(item),
        //       image: CachedNetworkImageProvider(item.bannerThumbnailUrl!),
        //       onPressRemove: () {
        //         ref.read(serviceImagesProvider.notifier).removeImage(index);
        //       },
        //     );
        //   },
        //   onReorder: (int oldIndex, int newIndex) =>
        //       reorderData(oldIndex, newIndex),
        // ),

        );
  }

  Widget _addMoreImages() {
    return Column(
      key: ValueKey("add"),
      children: [
        Container(
          height: 95,
          width: 90,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: TextButton(
            onPressed: widget.addMoreImages,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: const CircleBorder(),
              maximumSize: const Size(64, 36),
            ),
            child: Icon(Icons.add, color: VmodelColors.white),
          ),
        ),
      ],
    );
  }
}

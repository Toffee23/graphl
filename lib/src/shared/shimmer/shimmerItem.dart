import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vmodel/src/core/utils/enum/upload_ratio_enum.dart';
import 'package:vmodel/src/shared/shimmer/post_shimmer.dart';

Widget shimmerItem({
  bool useGrid = false,
  int numOfItem = 5,
  required BuildContext context,
}) {
  return useGrid
      ? SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int x = 0; x < numOfItem; ++x) ...[
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  child: Container(
                    color: Colors.white,
                    height: 150,
                    width: 150,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        )
      : SingleChildScrollView(
          child: Column(
            children: [
              for (int x = 0; x < numOfItem; ++x) ...[
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 40,
                      height: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ]
            ],
          ),
        );
}

Widget shimmerGalleryItem({
  bool useGrid = false,
  int numOfItem = 5,
  required BuildContext context,
}) {
  return useGrid
      ? SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: GridView.builder(
            shrinkWrap: true, // Add this line
            physics: NeverScrollableScrollPhysics(), // Add this line
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: UploadAspectRatio.portrait.ratio,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: numOfItem,
            itemBuilder: (context, index) {
              return const PostShimmerPage();
            },
          ),
        )
      : SingleChildScrollView(
          child: Column(
            children: [
              for (int x = 0; x < numOfItem; ++x) ...[
                Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  child: ListTile(
                    title: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white,
                    ),
                    subtitle: Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 40,
                      height: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ]
            ],
          ),
        );
}

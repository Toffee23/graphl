import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/post_comments_controller.dart';
import 'package:vmodel/src/features/dashboard/new_profile/controller/gallery_controller.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/modal_pill_widget.dart';
import '../controller/new_feed_provider.dart';

//ConsumerWidget
class DeleteFeatured extends ConsumerStatefulWidget {
  const DeleteFeatured({
    super.key,
    required this.postId,
    required this.albumId,
    required this.onRemoveFeatured,
  });

  final int postId;
  final int albumId;
  final VoidCallback onRemoveFeatured;

  @override
  ConsumerState<DeleteFeatured> createState() =>
      _DeleteFeaturedState();
}

class _DeleteFeaturedState
    extends ConsumerState<DeleteFeatured> {

  @override
  Widget build(BuildContext context) {

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          addVerticalSpacing(15),
          const VWidgetsModalPill(),
          addVerticalSpacing(25),
          Center(
            child: Text(
                'Are you sure you want to remove yourself from this post? This action cannot be undone.',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(
                  color: Theme.of(context).primaryColor,
                )),
          ),
          addVerticalSpacing(30),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: GestureDetector(
              onTap: () async {
                await ref.read(featuredProvider(widget.postId));
                widget.onRemoveFeatured();
                Navigator.pop(context);
                await ref.refresh(pBProvider(int.parse('${widget.albumId}')));
                ref.invalidate(pBProvider(int.parse('${widget.albumId}')));
                await ref.refresh(mainFeedProvider);
                ref.invalidate(mainFeedProvider);
                await ref.refresh(galleryFeedDataProvider);
                ref.invalidate(galleryFeedDataProvider);
                await ref.refresh(galleryProvider(null).future);

              },
              child: Text("Remove",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ),
          const Divider(
            thickness: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ),
          SizedBox(height: 10,)
        ]
    );
  }

}
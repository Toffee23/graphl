import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/features/deleted_posts/controller/deleted_post_controller.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';

class DeletedPostView extends ConsumerWidget {
  final String? userId;

  const DeletedPostView({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedPostsAsyncValue = ref.watch(deletedPostProvider(userId));

    return Scaffold(
      appBar: const VWidgetsAppBar(
        appbarTitle: "Deleted Posts",
        leadingIcon: VWidgetsBackButton(),
      ),
      body: deletedPostsAsyncValue.when(
        data: (deletedPosts) {
          if (deletedPosts.isEmpty) {
            return const Center(
              child: Text('No deleted posts found.'),
            );
          }
          return Padding(
            padding: const VWidgetsPagePadding.horizontalSymmetric(10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
              ),
              itemCount: deletedPosts.length,
              itemBuilder: (context, index) {
                final deletedPost = deletedPosts[index];
                final thumbnail = deletedPost.media?.isNotEmpty ?? false
                    ? deletedPost.media!.first.thumbnail
                    : null;

                return GestureDetector(
                  onTap: () {
                    // deletedPost
                    context.push('/restore_deleted_posts');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(.7)
                                    ],
                                    stops: [0.25, 0.75],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('${deletedPost.daysRemaining} days',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                                thumbnail ?? ''), // URL to your network image
                            fit: BoxFit.cover, // Cover the entire container
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                // return GridTile(
                //   child: Stack(
                //     children: [
                //       // Image section
                //       ClipRRect(
                //         borderRadius: BorderRadius.circular(10.0),
                //         child: thumbnail != null
                //             ? Image.network(
                //                 thumbnail,
                //                 fit: BoxFit.cover,
                //                 width: double.infinity,
                //                 height: double.infinity,
                //               )
                //             : Container(
                //                 color: Colors.grey[300],
                //                 child: const Icon(Icons.image_not_supported),
                //               ),
                //       ),
                //       // Days remaining overlay
                //       Positioned(
                //         bottom: 10,
                //         left: 10,
                //         right: 10,
                //         child: Center(
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(
                //               vertical: 2.0,
                //               horizontal: 8.0,
                //             ),
                //             decoration: BoxDecoration(
                //               color: Colors.black.withOpacity(0.7),
                //               borderRadius: BorderRadius.circular(5.0),
                //             ),
                //             child: Text(
                //               '${deletedPost.daysRemaining} days',
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
}

import 'package:vmodel/src/core/models/rating_model.dart';
import 'package:vmodel/src/features/reviews/widgets/review_card.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/vmodel.dart';


class BooingReviewPage extends StatefulWidget {
  const BooingReviewPage({
    super.key,
    required this.bookerReview,
    required this.bookieReview,
  });
  final Review? bookerReview;
  final Review? bookieReview;
  @override
  State<BooingReviewPage> createState() => _BooingReviewPageState();
}

class _BooingReviewPageState extends State<BooingReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? VmodelColors.lightBgColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: VWidgetsAppBar(
        appBarHeight: 50,
        leadingIcon: const VWidgetsBackButton(),

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appbarTitle: "Booking Review",
        // Text('My Reviews', style: VmodelTypography2.kTopTextStyle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10
              ),
              child: Text(
                'Bookie Review',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (widget.bookerReview == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text('No Review yet from booker'),
                ),
              )
            else
              ReviewCard(review: widget.bookerReview!),
            // Card(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Row(
            //       children: [
            //         ProfilePicture(
            //           url: widget.bookerReview!.reviewer.profilePicture,
            //           headshotThumbnail: widget.bookerReview!.reviewer.profilePicture,
            //         ),
            //         SizedBox(
            //           width: 5,
            //         ),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               widget.bookerReview!.reviewer.username,
            //               style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //                     fontWeight: FontWeight.w600,
            //                   ),
            //             ),
            //             SizedBox(
            //               height: 5,
            //             ),
            //             SizedBox(width: MediaQuery.sizeOf(context).width / 1.8, child: Text(widget.bookerReview!.reviewText)),
            //           ],
            //         ),
            //         Spacer(),
            //         Row(
            //           children: [
            //             Icon(
            //               Icons.star_rounded,
            //               color: Colors.amber,
            //             ),
            //             SizedBox(
            //               width: 2,
            //             ),
            //             Text(widget.bookerReview!.rating.toString())
            //           ],
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10
              ),
              child: Text(
                'Booker Review',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (widget.bookieReview == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text('No Review yet from bookie'),
                ),
              )
            else
              ReviewCard(
                review: widget.bookieReview!,
              )
          ],
        ),
      ),
    );
  }
}

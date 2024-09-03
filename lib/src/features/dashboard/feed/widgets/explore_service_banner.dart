import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vmodel/src/core/routing/routes.dart';
import 'package:vmodel/src/features/dashboard/dash/controller.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/feed_provider.dart';
import 'package:vmodel/src/features/settings/views/booking_settings/controllers/service_packages_controller.dart';
import 'package:vmodel/src/shared/html_description_widget.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../res/res.dart';
import '../../../settings/views/booking_settings/models/service_package_model.dart';

class PostServiceBookNowBanner extends StatefulWidget {
  PostServiceBookNowBanner({super.key, required this.service, required this.ref, required this.pauseVideo});
  final ServicePackageModel? service;
  final WidgetRef ref;
  Function() pauseVideo;

  @override
  State<PostServiceBookNowBanner> createState() => _PostServiceBookNowBannerState();
}

class _PostServiceBookNowBannerState extends State<PostServiceBookNowBanner> {
  bool showService = true;

  @override
  Widget build(BuildContext context) {
    //print('Services: ');
    //print(widget.service);
    return showService
        ? Stack(children: [
            if (widget.service != null)
              Consumer(builder: (context, ref, child) {
                return InkWell(
                    onTap: () {
                      // widget.pauseVideo.call();
                      //print('brrrrrrrrrrrrrrrrrrrr');
                      ref.read(inContentView.notifier).state = false;
                      ref.read(inContentScreen.notifier).state = false;
                      ref.read(dashTabProvider.notifier).colorsChangeBackGround(0);
                      widget.ref.read(serviceProvider.notifier).state = widget.service;
                      String? username = widget.service!.user?.username;
                      bool isCurrentUser = false;
                      String? serviceId = widget.service!.id;
                      context.push('${Routes.serviceDetail.split("/:").first}/$username/$isCurrentUser/$serviceId');
                      /*navigateToRoute(
                          context,
                          ServicePackageDetail(
                            service: service,
                            isCurrentUser: false,
                            username: service.user!.username,
                          ));*/
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
                      child: Card(
                        elevation: 4,
                        color: Colors.black,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: 65,
                                  height: 65,
                                  margin: EdgeInsets.only(top: 05, bottom: 05, left: 04),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider('${widget.service!.banner.firstOrNull?.url ?? widget.service?.user?.profilePictureUrl}'),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              addHorizontalSpacing(10),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                        text: TextSpan(
                                            text: '${widget.service!.title}',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                            children: [
                                              TextSpan(
                                                text: ' ${VMString.bullet} service',
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),
                                              )
                                            ]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    addVerticalSpacing(04),
                                     HtmlDescription(
      content: widget.service!.description,
      style: Style(
          color: Colors.white70,
          maxLines: 2,
          textOverflow: TextOverflow.ellipsis),
    ),
                                    // Text(
                                    //   '${widget.service!.description}',
                                    //   style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 12),
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    Row(
                                      children: [
                                        Text(
                                          'Book now',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 12),
                                        ),
                                        Icon(
                                          Icons.arrow_right_alt,
                                          color: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              addHorizontalSpacing(20),
                            ],
                          ),
                        ),
                      ),
                    ));
              }),
            if (widget.service != null)
              Positioned(
                top: 5,
                right: 15,
                child: InkWell(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  onTap: () {
                    showService = false;
                    setState(() {});
                  },
                  child: RenderSvg(
                    color: Colors.white,
                    svgPath: 'assets/icons/closeCircleFilled.svg',
                    svgHeight: 32,
                    svgWidth: 32,
                  ),
                ),
              ),
          ])
        : SizedBox.shrink();
  }
}

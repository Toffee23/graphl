import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vmodel/src/core/routing/navigator_1.0.dart';
import 'package:vmodel/src/core/utils/shared.dart';
import 'package:vmodel/src/core/utils/size_config.dart';
import 'package:vmodel/src/features/authentication/controller/auth_status_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/controller/new_feed_provider.dart';
import 'package:vmodel/src/features/dashboard/feed/model/feed_model.dart';
import 'package:vmodel/src/features/notifications/widgets/single_post_view.dart';
import 'package:vmodel/src/res/colors.dart';
import 'package:vmodel/src/shared/response_widgets/toast.dart';

  class WaitingRoom extends ConsumerStatefulWidget {
  const WaitingRoom({super.key, required this.name});
  final String? name;

  @override
  ConsumerState<WaitingRoom> createState() => _WaitingRoomState();
  }

  class _WaitingRoomState extends ConsumerState<WaitingRoom>  with SingleTickerProviderStateMixin{

    late AnimationController _controller;
    late Animation<double> _fadeInAnimation;
    late Animation<double> _fadeOutAnimation;
    double logoOpacity = 0.1;

  @override
  void initState(){

    Timer(Duration(seconds: 1), () {
      authenticate();
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2),
      ),
    );
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
    super.initState();
  }


    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

  Map<String, String> extractQueryParams(String url) {
    Uri uri = Uri.parse(url);
    if (uri.queryParameters.isEmpty) {
      return {};
    }
    return uri.queryParameters;
  }

    Future<void> authenticate() async {


      ref.watch(invalidateStaleDataProvider);

      // ref.watch(loginProvider);


    }


  void invalidPath(){
    context.push('/');
    VWidgetShowResponse.showToast(ResponseEnum.failed, message: "Invalid path");
  }

  void expiredLink(){
    context.push('/');
    VWidgetShowResponse.showToast(ResponseEnum.failed, message: "Expired link");
  }

  void createRooms()async{
    if(widget.name==null){
      context.push('/');
    }else{
      if(widget.name!.contains('https://vmodelapp.com')==false){
      context.push('/');
    }else{
      Map<String, String> query = extractQueryParams(widget.name!);
      if(query.isEmpty){
        context.push('/');
      }else{
        if(query['a']=='true'){
          switch (query['p']) {
            case 'post':{
              if(query['i']==null){expiredLink();}
              else{
                var post = await ref.read(mainFeedProvider.notifier).getSinglePost(postId: int.parse('${query['i'].toString().replaceAll('/', '')}'));
                if(post==null){expiredLink();}
                else{
                  navigateToRoute(context, SinglePostView(isCurrentUser: false, postSet: FeedPostSetModel.fromMap(post), deep:true));
              }
              }
            };
            default: {
              expiredLink();
            }
          }
        }
        else{
          try {
            context.push(query['p']!);
          }catch(e){
            invalidPath();
        }
      }

      }
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context,ref);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controller.value < 0.2
                          ? _fadeInAnimation.value
                          : _fadeOutAnimation.value,
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? VmodelAssets1.logoDark
                            : VmodelAssets1.logo,
                        height: 216,
                        width: 216,
                      ),
                    );
                  }),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? VmodelColors.background
                        : VmodelColors.mainColor,
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    'BETA',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? VmodelColors.background
                          : VmodelColors.mainColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

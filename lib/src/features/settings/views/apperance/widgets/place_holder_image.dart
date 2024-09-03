import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/controller/shake_detector_controller.dart';

class ProfileRingPlaceHolderImage extends ConsumerStatefulWidget {
  const ProfileRingPlaceHolderImage({super.key});

  @override
  ConsumerState<ProfileRingPlaceHolderImage> createState() =>
      _ProfileRingPlaceHolderImageState();
}

class _ProfileRingPlaceHolderImageState
    extends ConsumerState<ProfileRingPlaceHolderImage> {
  late final shakeController = ref.read(shakeDetectorProvivider);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width * 0.17,
        height: MediaQuery.of(context).size.width * 0.155,
        child: CachedNetworkImage(
          imageUrl:
              ref.watch(appUserProvider).valueOrNull?.profilePictureUrl ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

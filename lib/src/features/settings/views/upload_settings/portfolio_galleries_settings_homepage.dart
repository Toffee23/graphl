import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vmodel/src/core/controller/app_user_controller.dart';
import 'package:vmodel/src/core/utils/costants.dart';
import 'package:vmodel/src/core/utils/logs.dart';
import 'package:vmodel/src/features/dashboard/new_profile/model/gallery_model.dart';
import 'package:vmodel/src/features/settings/views/upload_settings/gallery_functions_widget.dart';
import 'package:vmodel/src/res/SnackBarService.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/animations/show_animated_dialog.dart';
import 'package:vmodel/src/shared/bottom_sheets/bottom_sheet.dart';
import 'package:vmodel/src/shared/bottom_sheets/model/bottom_sheet_item_model.dart';
import 'package:vmodel/src/shared/buttons/text_button.dart';
import 'package:vmodel/src/shared/loader/full_screen_dialog_loader.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/appbar/appbar.dart';
import 'package:vmodel/src/shared/loader/loader_progress.dart';
import 'package:vmodel/src/vmodel.dart';

import '../../../../core/utils/enum/album_type.dart';
import '../../../../shared/bottom_sheets/confirmation_bottom_sheet.dart';
import '../../../../shared/bottom_sheets/input_bottom_sheet.dart';
import '../../../../shared/bottom_sheets/tile.dart';
import '../../../create_posts/widgets/dialog_create_gallery.dart';
import '../../../dashboard/new_profile/controller/gallery_controller.dart';

/// state provider for loading state when re-ordering galleries
final _portfolioLoader = StateProvider((ref) => true);

class PortfolioGalleriesSettingsHomepage extends ConsumerStatefulWidget {
  const PortfolioGalleriesSettingsHomepage(
      {super.key, required this.title, required this.galleryType});
  final String title;
  final AlbumType galleryType;

  @override
  ConsumerState<PortfolioGalleriesSettingsHomepage> createState() =>
      _PortfolioGalleriesSettingsHomepageState();
}

class _PortfolioGalleriesSettingsHomepageState
    extends ConsumerState<PortfolioGalleriesSettingsHomepage> {
  final TextEditingController _controller = TextEditingController();
  late List<GalleryModel> portfolios = ref
          .read(galleryProvider(null))
          .valueOrNull
          ?.where((e) {
            return e.galleryType == widget.galleryType;
          })
          .where((x) => x.name.toLowerCase() != 'featured')
          .toList() ??
      [];

  @override
  Widget build(BuildContext context) {
    final galleries = ref.watch(galleryProvider(null));

    Widget proxyDecorator(
        Widget child, int index, Animation<double> animation) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue = Curves.easeInOut.transform(animation.value);
          // final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.02, animValue)!;
          return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: child,
          );
        },
        child: child,
      );
    }

    return Scaffold(
      appBar: VWidgetsAppBar(
        appbarTitle: widget.title,
        leadingIcon: VWidgetsBackButton(),
        trailingIcon: [
          // To Remove Add
          // VWidgetsTextButton(
          //     text: 'Add',
          //     onPressed: () {
          //       VMHapticsFeedback.lightImpact();
          //       showAnimatedDialog(context: context, child: (CreateGalleryDialog(isPolaroid: widget.galleryType == AlbumType.polaroid)));
          //     }),
        ],
      ),
      body: galleries.when(data: (values) {
        final updatedPortfolios = values
            .where((e) {
              return e.galleryType == widget.galleryType;
            })
            .where((x) => x.name.toLowerCase() != 'featured')
            .toList();
        final oldIds = portfolios.map((x) => int.parse(x.id)).toList();
        final refreshedIds =
            updatedPortfolios.map((x) => int.parse(x.id)).toList();

        // logger.d(oldIds);
        logger.f(refreshedIds);

        // if (!listEquals(oldIds, refreshedIds)) {
        //   setState(() => portfolios = updatedPortfolios);
        // }
        // setState(() {

        // });
        return Column(
          children: [
            if (portfolios.isEmpty) ...[
              addVerticalSpacing(300),
              Center(child: Text("No Gallery")),
            ],
            if (portfolios.isNotEmpty) ...[
              Expanded(
                child: ReorderableListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    for (int index = 0; index < portfolios.length; index += 1)
                      ReorderableDragStartListener(
                        key: Key('$index'),
                        index: index,
                        child: VWidgetsGalleryFunctionsCard(
                          title: portfolios[index].name,
                          onTapEdit: () {
                            _controller.text = '';
                            showModalBottomSheet(
                                context: context,
                                useRootNavigator: true,
                                isScrollControlled: true,
                                constraints: BoxConstraints(maxHeight: 50.h),
                                backgroundColor: Colors.transparent,
                                builder: (controller) {
                                  return Container(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: VConstants
                                          .bottomPaddingForBottomSheets,
                                    ),
                                    decoration: BoxDecoration(
                                      // color: VmodelColors.white,
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(13),
                                      ),
                                    ),
                                    child: VWidgetsInputBottomSheet(
                                      controller: _controller,
                                      title: "${portfolios[index].name}",
                                      hintText: "${portfolios[index].name}",
                                      dialogMessage: "Edit gallery name",
                                      actions: [
                                        VWidgetsBottomSheetTile(
                                          message: "Update",
                                          onTap: () async {
                                            final id = int.tryParse(
                                                portfolios[index].id);
                                            if (id == null) {
                                              return;
                                            }

                                            if (_controller.text.isEmpty) {
                                              SnackBarService().showSnackBar(
                                                  message:
                                                      "Field cannot be empty",
                                                  icon: VIcons.emptyIcon,
                                                  context: context);
                                              return;
                                            }
                                            await ref
                                                .read(galleryProvider(null)
                                                    .notifier)
                                                .upadetGalleryName(
                                                    galleryId: id,
                                                    name:
                                                        _controller.text.trim(),
                                                    context: context)
                                                .then((value) {
                                              _controller.text = '';
                                              ref.invalidate(
                                                  galleryProvider(null));
                                              goBack(context);
                                            });
                                          },
                                        ),
                                        const Divider(thickness: 0.5),
                                        VWidgetsBottomSheetTile(
                                          message: "Cancel",
                                          onTap: () {
                                            goBack(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            // showDialog(
                            //     context: context,
                            //     builder: ((context) => VWidgetsAddAlbumPopUp(
                            //           controller: _controller,
                            //           popupTitle: "Edit Gallery Name",
                            //           buttonTitle: "Done",
                            //           onPressed: () async {
                            //             final id =
                            //                 int.tryParse(portfolios[index].id);
                            //             if (id == null) {
                            //               //print('gallery ID to rename is null');
                            //               return;
                            //             }
                            //             goBack(context);
                            //             VLoader.changeLoadingState(true);
                            //             ref
                            //                 .read(galleryProvider(null).notifier)
                            //                 .upadetGalleryName(
                            //                     galleryId: id,
                            //                     name: _controller.text.trim())
                            //                 .then((value) {
                            //               _controller.text = '';
                            //               VLoader.changeLoadingState(false);
                            //               //  ref.invalidate(galleryProvider(null));
                            //             });
                            //           },
                            //         )));
                          },
                          onTapDelete: () async {
                            final bool? first =
                                await showModalBottomSheet<bool?>(
                                    context: context,
                                    useRootNavigator: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) {
                                      _controller.text = '';
                                      return Container(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          bottom: VConstants
                                              .bottomPaddingForBottomSheets,
                                        ),
                                        decoration: BoxDecoration(
                                          // color: VmodelColors.white,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(13),
                                          ),
                                        ),
                                        child: VWidgetsConfirmationBottomSheet(
                                          title:
                                              "Delete ${portfolios[index].name}",
                                          dialogMessage:
                                              "Are you sure want to delete this gallery?"
                                              " This action cannot be undone!",
                                          actions: [
                                            VWidgetsBottomSheetTile(
                                              message: "Delete",
                                              onTap: () {
                                                Navigator.pop(context, true);
                                              },
                                            ),
                                            const Divider(thickness: 0.5),
                                            VWidgetsBottomSheetTile(
                                              message: "Cancel",
                                              onTap: () {
                                                Navigator.pop(context, false);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    });

                            if (first != null && first && context.mounted) {
                              showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return Container(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        bottom: VConstants
                                            .bottomPaddingForBottomSheets,
                                      ),
                                      decoration: BoxDecoration(
                                        // color: VmodelColors.white,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(13),
                                        ),
                                      ),
                                      child: VWidgetsInputBottomSheet(
                                        controller: _controller,
                                        title: "${portfolios[index].name}",
                                        dialogMessage:
                                            "Please enter you password to proceed",
                                        hintText: 'Password',
                                        obscureText: true,
                                        actions: [
                                          VWidgetsBottomSheetTile(
                                            message: "Delete",
                                            onTap: () async {
                                              final id = int.tryParse(
                                                  portfolios[index].id);
                                              if (id == null) {
                                                return;
                                              }
                                              // goBack(context);
                                              // VLoader.changeLoadingState(true);
                                              VLoader.changeLoadingState(true,
                                                  context: context);

                                              ref
                                                  .read(galleryProvider(null)
                                                      .notifier)
                                                  .deleteGallery(
                                                      galleryId: id,
                                                      userPassword:
                                                          _controller.text,
                                                      context: context)
                                                  .then((value) {
                                                print("hello world $value");

                                                if (!value!) {
                                                  SnackBarService().showSnackBar(
                                                      message:
                                                          "Failed to delete gallery",
                                                      context: context);
                                                } else {
                                                  SnackBarService().showSnackBar(
                                                      message:
                                                          "Gallery deleted successfuly",
                                                      context: context);
                                                }

                                                _controller.text = '';
                                                ref.invalidate(
                                                    galleryProvider(null));

                                                goBack(context);
                                                goBack(context);

                                                // // VLoader.changeLoadingState(false);
                                              });
                                            },
                                          ),
                                          const Divider(thickness: 0.5),
                                          VWidgetsBottomSheetTile(
                                            message: "Cancel",
                                            onTap: () {
                                              goBack(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            }

                            // final bool? first = await showDialog<bool>(
                            //     context: context,
                            //     builder: ((context) => VWidgetsConfirmationPopUp(
                            //         popupTitle: "Delete Gallery",
                            //         firstButtonText: "Delete",
                            //         secondButtonText: "Go Back",
                            //         popupDescription:
                            //             "Are you sure want to delete this Gallery ? This action cannot be undone!",
                            //         onPressedYes: () {
                            //           Navigator.pop(context, true);
                            //           // _controller.text = '';
                            //         },
                            //         onPressedNo: () {
                            //           // _controller.text = '';
                            //           Navigator.pop(context, false);
                            //         })));

                            // if (first != null && first && context.mounted) {
                            //   _controller.text = '';
                            //   showDialog(
                            //       context: context,
                            //       builder: ((context) => VWidgetsAddAlbumPopUp(
                            //             textFieldlabel: "Enter your Password",
                            //             controller: _controller,
                            //             popupTitle: "Delete Gallery",
                            //             buttonTitle: "Delete",
                            //             hintText: "Enter Password",
                            //             obscureText: true,
                            //             onPressed: () async {
                            //               final id =
                            //                   int.tryParse(portfolios[index].id);
                            //               if (id == null) {
                            //                 //print('gallery ID to delete is null');
                            //                 return;
                            //               }
                            //               goBack(context);
                            //               VLoader.changeLoadingState(true);
                            //               ref
                            //                   .read(
                            //                       galleryProvider(null).notifier)
                            //                   .deleteGallery(
                            //                       galleryId: id,
                            //                       userPassword: _controller.text)
                            //                   .then((value) {
                            //                 _controller.text = '';
                            //                 VLoader.changeLoadingState(false);
                            //                 ref.invalidate(galleryProvider(null));
                            //               });
                            //             },
                            //           )));
                            // }
                          },
                        ),
                      )
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                    });
                    setState(() {
                      final item = portfolios.removeAt(oldIndex);
                      portfolios.insert(newIndex, item);
                    });
                    VBottomSheetComponent.actionBottomSheet<bool>(
                      context: context,
                      actions: [
                        VBottomSheetItem(
                            onTap: () async {
                              showAnimatedDialog(
                                barrierColor: Colors.black54,
                                context: context,
                                child: Consumer(builder: (context, ref, child) {
                                  return LoaderProgress(
                                    done: !ref.watch(_portfolioLoader),
                                    loading: ref.watch(_portfolioLoader),
                                  );
                                }),
                              );
                              final updateGallery = await ref
                                  .read(galleryProvider(null).notifier)
                                  .updateGalleryOrder(
                                    portfolios
                                        .where((x) =>
                                            x.name.toLowerCase() != 'featured')
                                        .map((x) => int.parse(x.id))
                                        .toList(),
                                  );

                              if (!updateGallery) {
                                SnackBarService()
                                    .showSnackBarError(context: context);
                                final item = portfolios.removeAt(newIndex);
                                portfolios.insert(oldIndex, item);
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                                return;
                              }
                              await ref.refresh(appUserProvider.future);
                              final update = await ref
                                  .refresh(galleryProvider(null))
                                  .valueOrNull;
                              logger.i(update
                                      ?.map((x) => int.parse(x.id))
                                      .toList() ??
                                  []);
                              ref.read(_portfolioLoader.notifier).state = false;
                              Future.delayed(Duration(seconds: 2), () async {
                                Navigator.of(context)
                                  ..pop()
                                  ..pop();
                              });
                              // Navigator.pop(context);
                            },
                            title: 'Reorder Gallery'),
                        VBottomSheetItem(
                            onTap: () {
                              setState(() {
                                final item = portfolios.removeAt(newIndex);
                                portfolios.insert(oldIndex, item);
                              });
                              Navigator.pop(context);
                            },
                            title: 'Cancel'),
                      ],
                    );
                  },
                  proxyDecorator: proxyDecorator,
                ),
              )
              // addVerticalSpacing(20),
              // ...List.generate(portfolios.length, (index) {
              //   return  }),
            ],
          ],
        );
      }, error: (error, stackTrace) {
        return const Center(child: Text('Error'));
      }, loading: () {
        return const Center(child: CircularProgressIndicator.adaptive());
      }),
    );
  }
}

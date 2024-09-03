import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/res/res.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';
import 'package:vmodel/src/vmodel.dart';

class VWidgetsStackVideo extends StatelessWidget {
  final ImageProvider<Object> image;
  final VoidCallback? bottomLeftIconOnPressed;
  final VoidCallback? topRightIconOnPressed;
  final VoidCallback? onTapImage;
  final VoidCallback? onTapCover;
  final bool isImageSelected;

  const VWidgetsStackVideo(
      {required this.image,
      this.bottomLeftIconOnPressed,
      this.topRightIconOnPressed,
      this.onTapImage,
      this.isImageSelected = false,
      super.key,
      this.onTapCover});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: <Widget>[
              GestureDetector(
                onTap: onTapImage,
                child: Container(
                  height: 300,
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      // height: 300,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(08),
                            bottomLeft: Radius.circular(08)),
                        gradient: LinearGradient(
                            end: Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                            colors: [
                              VmodelColors.primaryColor,
                              Color(0xffB58D8D)
                            ]),
                      ),
                      child: Center(
                        child: Text(
                          'Trim',
                          // style: textFieldTitleTextStyle,
                          style: context.textTheme.displayMedium
                              ?.copyWith(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isImageSelected)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      //use VIcons here
                      icon: RenderSvg(
                        // svgPath: VIcons.trashIcon,
                        svgPath: VIcons.remove,
                        color: VmodelColors.white,
                      ),
                      color: VmodelColors.white,
                      onPressed: bottomLeftIconOnPressed),
                ),
            ],
          ),
          Stack(
            alignment: AlignmentDirectional.topStart,
            children: <Widget>[
              GestureDetector(
                onTap: onTapCover,
                child: Container(
                  height: 300,
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(image: image, fit: BoxFit.cover),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      // height: 300,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(08),
                            bottomLeft: Radius.circular(08)),
                        gradient: LinearGradient(
                            end: Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                            colors: [
                              VmodelColors.primaryColor,
                              Color(0xffB58D8D)
                            ]),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Cover',
                          // style: textFieldTitleTextStyle,
                          style: context.textTheme.displayMedium
                              ?.copyWith(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // if (isImageSelected)
              //   Align(
              //     alignment: Alignment.topRight,
              //     child: IconButton(
              //         //use VIcons here
              //         icon: RenderSvg(
              //           // svgPath: VIcons.trashIcon,
              //           svgPath: VIcons.remove,
              //           color: VmodelColors.white,
              //         ),
              //         color: VmodelColors.white,
              //         onPressed: bottomLeftIconOnPressed),
              //   ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vmodel/src/res/icons.dart';
import 'package:vmodel/src/shared/rend_paint/render_svg.dart';

class RatingStar extends StatelessWidget {
  final double rate;
  final double size;

  RatingStar({Key? key, required this.rate, this.size = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(
        Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          child: RenderSvg(
            svgPath: VIcons.star,
            svgHeight: size,
            svgWidth: size,
            color:
                rate > i ? Colors.amber : Theme.of(context).iconTheme.color,
          ),
        ),
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
  }
}

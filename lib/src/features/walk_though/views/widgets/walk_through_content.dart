import 'package:flutter/material.dart';

class WalkThroughContent extends StatelessWidget {
  final String? textContent;
  final String? desContent;
  final String? walkImg;
  final int? currentIndexPage;

  WalkThroughContent({Key? key, this.textContent, this.walkImg, this.desContent, this.currentIndexPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: h * 0.02),
          // SizedBox(
          //   height: h / 1.80,
          // ),
          // Center(
          //   child: Stack(
          //     children: [
          //       Container(
          //           height: h / 1.80,
          //           width: width,
          //           padding: EdgeInsets.symmetric(horizontal: 20),
          //           alignment: Alignment.center,
          //           child: ColorFiltered(
          //             colorFilter: ColorFilter.mode(
          //                 Theme.of(context).primaryColor, BlendMode.modulate),
          //             child: Lottie.asset(
          //               Theme.of(context).brightness == Brightness.dark
          //                   ? 'assets/images/animations/walk_though.json'
          //                   : 'assets/images/animations/walk_though.json',
          //               // delegates: LottieDelegates(
          //               //   values: [
          //               //     ValueDelegate.color(
          //               //       // keyPath order: ['layer name', 'group name', 'shape name']
          //               //       const ['**', 'Ã¥Â½Â¢Ã§ÂÂ¶Ã¥ÂÂ¾Ã¥Â±Â 8', '**'],
          //               //       value: Colors.white,
          //               //     ),
          //               //   ],
          //               // ),
          //             ),
          //           )),
          //       Positioned(
          //         height: h / 1.80,
          //         width: width,
          //         child: Center(
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(100),
          //             child: Image.asset(
          //               width:  width/2.4,
          //               Theme.of(context).brightness == Brightness.dark
          //                   ? VmodelAssets1.logoDark
          //                   : VmodelAssets1.logo,
          //             ),
          //           ),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          // SizedBox(height: h * 0.020),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$textContent',
                textAlign: TextAlign.start, style: Theme.of(context).textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 20, color: Theme.of(context).primaryColor)),
          ),
          SizedBox(height: h * 0.020),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(0.75)),
              child: Text('$desContent',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}

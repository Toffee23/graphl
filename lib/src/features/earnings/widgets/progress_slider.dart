import 'package:flutter/material.dart';

class ProgressSlide extends StatefulWidget {
  final double progress; // Value between 0.0 and 1.0 representing completion
  final Widget child; // The widget to slide

  const ProgressSlide({Key? key, required this.progress, required this.child}) : super(key: key);

  @override
  State<ProgressSlide> createState() => _ProgressSlideState();
}

class _ProgressSlideState extends State<ProgressSlide> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRect(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: SizedBox(
              width: MediaQuery.of(context).size.width/3, // Slide fills available width
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                      color: Theme.of(context).primaryColor,
                    ),
                    // Background for unfilled progress
                    width: (MediaQuery.of(context).size.width/3) * widget.progress,
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                      color: Colors.grey,
                    ),
                    // Color for filled progress
                    width: (MediaQuery.of(context).size.width/3) * (1.0 - widget.progress), // Remaining width
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: (MediaQuery.of(context).size.width/3) * widget.progress, // Position based on progress
          top: -1.0,
          child: Container(
            height: 15.0, // Marker height
            width: 3.0, // Marker width
            color: Theme.of(context).primaryColor, // Marker color
          ),
        ),
        Center(child: widget.child), // Child widget displayed on top
      ],
    );
  }
}

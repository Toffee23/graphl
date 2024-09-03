import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HintDialogue extends StatefulWidget {
  const HintDialogue({
    super.key,
    this.onTapDialogue,
    required this.text,
    this.margin,
    this.positionWrapped = true,
  });
  final VoidCallback? onTapDialogue;
  final String text;
  final EdgeInsetsGeometry? margin;
  final bool positionWrapped;

  @override
  State<HintDialogue> createState() => _HintDialogueState();
}

class _HintDialogueState extends State<HintDialogue>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Adjust the duration as needed
    )..repeat(reverse: true);
    ;

    // Define the fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack, // Adjust the curve as needed
    ));

    // Start the animation when the widget is created
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose of the animation controller when the widget is disposed
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.positionWrapped) return _buildHintWidget();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: _buildHintWidget(),
    );
  }

  SafeArea _buildHintWidget() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTapDialogue,
          child: Container(
            // constraints: BoxConstraints(maxWidth: 50),
            // width: 50,
            height: 30,
            margin: widget.margin ??
                EdgeInsets.only(top: 10, bottom: 10, right: 10.w, left: 50.w),
            child: Text(
              widget.text,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 9.sp, fontWeight: FontWeight.w600),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.transparent
                      : Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

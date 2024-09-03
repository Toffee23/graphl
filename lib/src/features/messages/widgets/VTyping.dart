import 'dart:async';
import 'dart:core';


import 'package:vmodel/src/vmodel.dart';




class VTyping extends StatefulWidget {
  VTyping();

  @override
  State<VTyping> createState() => _VTypingState();
}

class _VTypingState extends State<VTyping> with TickerProviderStateMixin{
  bool isTyping = true;
  late AnimationController _typingController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    Timer(Duration(seconds:5),(){
      setState(() {
        isTyping = false;
      });
    });

    _typingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_typingController);
    _typingController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(isTyping) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Icon(
              Icons.fiber_manual_record,
              size: 12.0,
              color: Colors.grey,
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.fiber_manual_record,
                size: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation.drive(CurveTween(curve: Curves.easeInOut)),
            child: Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Icon(
                Icons.fiber_manual_record,
                size: 12.0,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }else{
      return SizedBox.shrink();
    }

  }
}
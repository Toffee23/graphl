import 'package:flutter/cupertino.dart';

class DisplayBoards extends StatefulWidget {
  DisplayBoards({required this.boardWidget,super.key});
  Widget boardWidget;

  @override
  State<DisplayBoards> createState() => _DisplayBoardsState();
}

class _DisplayBoardsState extends State<DisplayBoards> {
  @override
  Widget build(BuildContext context) {
    return widget.boardWidget;
  }
}

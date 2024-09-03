import 'package:vmodel/src/features/messages/model/messages_model.dart';

class MessageRouteModel {
  final bool deep;
  final List<MessageModel> messages;

  MessageRouteModel({this.deep = false, required this.messages});
}

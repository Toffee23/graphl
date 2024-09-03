import 'package:flutter/widgets.dart';

final _REGEX_EMOJI = RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])');

extension EmojiExtension on String {
  RichText get buildRichText {
    final List<TextSpan> children = [];
    for (var character in this.characters) {
      if (_REGEX_EMOJI.allMatches(character).isNotEmpty) {
        children.add(TextSpan(text: character, style: TextStyle(fontSize: 20.0))); // Increase size for Emojis
      } else {
        children.add(TextSpan(text: character)); // Default size for text
      }
    }
    return RichText(text: TextSpan(children: children));
  }
}

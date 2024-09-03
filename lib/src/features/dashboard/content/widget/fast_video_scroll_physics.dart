import 'package:flutter/material.dart';

class FastContentViewPageViewScrollPhysics extends ScrollPhysics {
  const FastContentViewPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  FastContentViewPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastContentViewPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 0.8,
      );
}

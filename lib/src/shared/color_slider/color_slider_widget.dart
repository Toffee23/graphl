//  Forked from IGLU COLOR PICKER
// Copyright © 2020 - 2023 IGLU. All rights reserved.
// Copyright © 2020 - 2023 IGLU S.r.l.s.

import 'package:flutter/material.dart';

import 'color_picker_slider.dart';
import 'track_type.dart';

/// The default layout of Color Picker.
class VMColorPicker extends StatefulWidget {
  const VMColorPicker({
    super.key,
    //GENERAL
    this.paletteType = VMIGPaletteType.hsv,
    this.currentColor,
    this.onColorChanged,
    // //HISTORY
    this.historyColorsBuilder,
    this.colorHistory,
    // //ALL VIEWS DECORATION
    // this.enableAlpha = true,
    this.padding,
    this.elementSpacing = 10,
    // //DECORATION COLOR PICKER SLIDER
    this.showSlider = true,
    this.sliderRadius,
    this.sliderBorderColor,
    this.sliderBorderWidth,
    this.displayThumbColor = true,
    });

  //GENERAL
  final VMIGPaletteType paletteType;

  final Color? currentColor;
  final ValueChanged<Color>? onColorChanged;

  //HISTORY
  final Widget Function()? historyColorsBuilder;
  final List<Color>? colorHistory;

  //ALL VIEWS DECORATION
  final EdgeInsetsGeometry? padding;
  final double elementSpacing;

  //DECORATION COLOR PICKER SLIDER
  final bool showSlider;
  final double? sliderRadius;
  final Color? sliderBorderColor;
  final double? sliderBorderWidth;
  final bool displayThumbColor;


  @override
  VMColorPickerState createState() => VMColorPickerState();
}

class VMColorPickerState extends State<VMColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0, 0, 0, 0);
  List<Color> colorHistory = [];

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(
      widget.currentColor ?? Colors.white,
    );
    if (widget.colorHistory != null) {
      colorHistory = widget.colorHistory ?? [];
    }
    super.initState();
  }

  @override
  void didUpdateWidget(VMColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(
      widget.currentColor ?? Colors.white,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //COLOR PICKER SLIDER & ALPHA SLIDER
          // _sliderByPaletteType,
          VMIGColorPickerSlider(
            trackType: VMIGTrackType.hue,
            hsvColor: currentHsvColor,
            onColorChanged: (HSVColor color) {
              setState(() => currentHsvColor = color);
              widget.onColorChanged?.call(currentHsvColor.toColor());
            },
            // displayThumbColor: widget.displayThumbColor,
            displayThumbColor: true,
            borderColor: Colors.transparent,
            borderWidth: 0,
            radius: widget.sliderRadius,
          ),
          // _colorPickerSlider(IGTrackType.hue),
        ],
      ),
    );
  }

  //UTILS
  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged?.call(currentHsvColor.toColor());
  }

  //WIDGETS

  Widget get space {
    return SizedBox(height: widget.elementSpacing);
  }
}

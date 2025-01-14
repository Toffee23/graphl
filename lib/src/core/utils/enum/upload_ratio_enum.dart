import 'package:flutter/services.dart';

/// [UploadAspectRatio] this enum controls the aspect ratio for for uploaded content
/// either videos or pictures
enum UploadAspectRatio implements Comparable<UploadAspectRatio> {
  ///[square] aspect ratio for both videos and picture on VModel
  square(id: 1, xScale: 1, yScale: 1, apiValue: 'square'),

  ///[portrait] aspect ratio for both videos and picture on VModel
  portrait(id: 2, xScale: 4, yScale: 5, apiValue: 'portrait'),

  ///[pro] or fullscreen aspect ratio for both videos and picture on VModel
  pro(id: 1, xScale: 2, yScale: 3, apiValue: 'pro'),

  ///[wide] aspect ratio for both videos and picture on VModel
  wide(id: 3, xScale: 3, yScale: 2, apiValue: 'wide');

  const UploadAspectRatio({required this.id, required this.xScale, required this.yScale, required this.apiValue});
  final int id;

  ///[xScale] for the uploaded content
  final int xScale;

  ///[yScale] for the uploaded content
  final int yScale;

  final String apiValue;

  ///resolved [ratio] value for the [xScale] & [yScale]
  double get ratio => xScale / yScale;
  String get simpleName => "$xScale:$yScale";

  static UploadAspectRatio aspectRatioByApiValue(String apiValue) {
    return UploadAspectRatio.values.firstWhere((value) => value.apiValue == apiValue, orElse: () => UploadAspectRatio.square);
  }

  @override
  int compareTo(UploadAspectRatio other) => id - other.id;

  @override
  String toString() => simpleName;
}

extension UploadAspectRatioExtension on UploadAspectRatio {
  ///Returns the y-dimension given the x-dimension as input
  double yDimensionFromX(double xValue) {
    return (xValue / this.xScale.toDouble()) * this.yScale.toDouble();
  }

  ///Returns the x-dimension given the y-dimension as input
  double xDimensionFromY(double yValue) {
    return (yValue / this.yScale.toDouble()) * this.xScale.toDouble();
  }

  ///Returns a Size object with the given x-dimension conforming
  /// to this aspect ratio
  Size sizeFromX(double xValue) {
    return Size(xValue, yDimensionFromX(xValue));
  }

  ///Returns a Size object with the given y-dimension conforming
  /// to this aspect ratio
  Size sizeFromY(double yValue) {
    return Size(yValue, yDimensionFromX(yValue));
  }

  ///return aspect ratio value for both [x] as the width of the video and [y] as the height
  double customAspectRatio(num x, num y) => (x / y);
}

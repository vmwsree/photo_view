import 'dart:math' as math;
import 'dart:ui';

import 'package:photo_view/photo_view.dart';

double getScaleForScaleState(
    PhotoViewScaleState scaleState, ScaleBoundaries scaleBoundaries) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
    case PhotoViewScaleState.zooming:
      return _clampSize(scaleBoundaries.initialScale, scaleBoundaries);
    case PhotoViewScaleState.covering:
      return _clampSize(
          _scaleForCovering(
              scaleBoundaries.outerSize, scaleBoundaries.childSize),
          scaleBoundaries);
    case PhotoViewScaleState.originalSize:
      return _clampSize(1.0, scaleBoundaries);
    default:
      return null;
  }
}

class ScaleBoundaries {
  const ScaleBoundaries(this._minScale, this._maxScale, this._initialScale,
      this.outerSize, this.childSize);

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  final Size outerSize;
  final Size childSize;

  double get minScale {
    assert(_minScale is double || _minScale is PhotoViewComputedScale);
    if (_minScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);
    return _minScale;
  }

  double get maxScale {
    assert(_maxScale is double || _maxScale is PhotoViewComputedScale);
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (_scaleForContained(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (_scaleForCovering(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    return _maxScale.clamp(minScale, double.infinity);
  }

  double get initialScale {
    assert(_initialScale is double || _initialScale is PhotoViewComputedScale);
    if (_initialScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    return _initialScale.clamp(minScale, maxScale);
  }
}

double _scaleForContained(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _scaleForCovering(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _clampSize(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}

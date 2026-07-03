// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Lato-Black.ttf
  String get latoBlack => 'assets/fonts/Lato-Black.ttf';

  /// File path: assets/fonts/Lato-Bold.ttf
  String get latoBold => 'assets/fonts/Lato-Bold.ttf';

  /// File path: assets/fonts/Lato-Light.ttf
  String get latoLight => 'assets/fonts/Lato-Light.ttf';

  /// File path: assets/fonts/Lato-Regular.ttf
  String get latoRegular => 'assets/fonts/Lato-Regular.ttf';

  /// File path: assets/fonts/Lato-Thin.ttf
  String get latoThin => 'assets/fonts/Lato-Thin.ttf';

  /// File path: assets/fonts/Lato_Semibold.ttf
  String get latoSemibold => 'assets/fonts/Lato_Semibold.ttf';

  /// List of all assets
  List<String> get values => [
    latoBlack,
    latoBold,
    latoLight,
    latoRegular,
    latoThin,
    latoSemibold,
  ];
}

class $AssetsPngGen {
  const $AssetsPngGen();

  /// File path: assets/png/ic_home_header.png
  AssetGenImage get icHomeHeader =>
      const AssetGenImage('assets/png/ic_home_header.png');

  /// List of all assets
  List<AssetGenImage> get values => [icHomeHeader];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsPngGen png = $AssetsPngGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

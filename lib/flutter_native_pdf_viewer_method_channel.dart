import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_native_pdf_viewer_platform_interface.dart';

/// An implementation of [FlutterNativePdfViewerPlatform] that uses method channels.
class MethodChannelFlutterNativePdfViewer extends FlutterNativePdfViewerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_native_pdf_viewer');

  @override
  Future<bool?> openPdf({
    required String path,
  }) {
    return methodChannel.invokeMethod<bool>('openPdf', {'path': path});
  }
}

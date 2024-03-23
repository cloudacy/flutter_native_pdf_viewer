import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_native_pdf_viewer_method_channel.dart';

abstract class FlutterNativePdfViewerPlatform extends PlatformInterface {
  /// Constructs a FlutterNativePdfViewerPlatform.
  FlutterNativePdfViewerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterNativePdfViewerPlatform _instance = MethodChannelFlutterNativePdfViewer();

  /// The default instance of [FlutterNativePdfViewerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterNativePdfViewer].
  static FlutterNativePdfViewerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterNativePdfViewerPlatform] when
  /// they register themselves.
  static set instance(FlutterNativePdfViewerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> openPdf({
    required String path,
  }) {
    throw UnimplementedError('openPdf(path: String) has not been implemented.');
  }
}

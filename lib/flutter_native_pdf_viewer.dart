import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_native_pdf_viewer_platform_interface.dart';

class FlutterNativePdfViewer extends StatelessWidget {
  /// This is used in the platform side to register the view.
  static const _viewType = 'flutter_native_pdf_viewer';

  /// Path to the PDF file, which can be accessed by the platform.
  final String path;

  /// Create a new FlutterNativePDFViewer widget, which allows to view a PDF at given `path`,
  /// using the native PDF viewer on iOS devices.
  const FlutterNativePdfViewer({
    super.key,
    required this.path,
  });

  /// Sends an "open PDF" command to the platform.
  ///
  /// It should be used on Android devices, since Android doesn't provide an in-App native PDF viewer.
  ///
  /// On iOS, the Widget itself may be used to render the PDF inside the app.
  static Future<bool> openPdf({
    required String path,
  }) async {
    return (await FlutterNativePdfViewerPlatform.instance.openPdf(path: path)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: {'path': path},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Text(
        'Android doesn\'t provide an in-App native PDF viewer. Please use the static openPdf method on Android devices.',
      );
    }
  }
}

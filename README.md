# flutter_native_pdf_viewer

A lightweight PDF viewer for iOS (>= 12.0) and Android, using platform-native elements.

## Example

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_pdf_viewer/flutter_native_pdf_viewer.dart';

class ExampleWidget extends StatefulWidget {
  final File pdf;

  ExampleWidget({
    required this.pdf,
  });

  @override
  _ExampleWidgetState createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  @override
  void initState() {
    super.initState();

    // Share a PDF to be opened by an external PDF viewer app on android devices.
    // The app must allow "share" access to the path of the given file.
    // See **Installation** section for more details.
    if (Platform.isAndroid) {
      FlutterNativePdfViewer.openPdf(path: widget.pdf.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    // iOS provides an in-App option, using PDFKit.
    if (Platform.isIOS) {
      return FlutterNativePdfViewer(path: widget.pdf.path);
    } else {
      return Text('Not supported.');
    }
  }
}
```

## Installation

Add

```yaml
flutter_native_pdf_viewer: ^3.0.0
```

to the `dependencies` section of the `pubspec.yaml` file.

### Android

On Android devices, PDFs are opened with an external PDF viewer and therefore have to be "shared".
To allow file-access to other apps, you have to add following FileProvider config:

At `android/app/src/main/AndroidManifest.xml`, add

```xml
<manifest>
    ...
    <application>
        ...
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths" />
        </provider>
        ...
    </application>
</manifest>
```

At `android/app/src/main/res/xml/provider_paths.xml`, add

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- When using files from the cache directory -->
    <cache-path name="cache-path" path="." />

    <!-- See https://developer.android.com/reference/androidx/core/content/FileProvider#SpecifyFiles for more path options -->
</paths>
```

Depending on the file location, the path config has to be set differently.

For more details, please check https://developer.android.com/reference/androidx/core/content/FileProvider.

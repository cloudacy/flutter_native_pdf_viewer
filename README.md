# flutter_native_pdf_viewer

A lightweight PDF viewer for iOS and Android, using platform-native elements.


## Installation

Add `flutter_native_pdf_viewer: ^1.0.0` to the `dependencies` section of the `pubspec.yaml` file.

### android

On Android devices, PDFs are opened with an external PDF viewer and therefore have to be "shared".
To allow file-access to other apps, you have to add following FileProvider config:

At `android/app/src/main/AndroidManifest.xml`, add

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/provider_paths" />
</provider>
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

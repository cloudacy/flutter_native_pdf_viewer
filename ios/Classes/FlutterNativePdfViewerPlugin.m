#import "FlutterNativePdfViewerPlugin.h"
#if __has_include(<flutter_native_pdf_viewer/flutter_native_pdf_viewer-Swift.h>)
#import <flutter_native_pdf_viewer/flutter_native_pdf_viewer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_native_pdf_viewer-Swift.h"
#endif

@implementation FlutterNativePdfViewerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativePdfViewerPlugin registerWithRegistrar:registrar];
}
@end

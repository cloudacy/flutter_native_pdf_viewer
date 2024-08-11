import 'dart:async';
import 'dart:io';
import 'dart:math' show min, max;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'flutter_native_pdf_viewer_platform_interface.dart';

class FlutterNativePdfViewerSearchController {
  final TextEditingController _searchFieldController = TextEditingController();

  /// Should represent the current search result size, provided by the platform.
  /// Should only be updated, if a new size was reported by the platform.
  final ValueNotifier<int> _searchResultSize = ValueNotifier(0);

  /// Should represent the current search result index, provided by the platform.
  /// Should only be updated, if a new index was reported by the platform.
  final ValueNotifier<int> _searchResultIndex = ValueNotifier(0);

  /// Used to send search result index updates from Flutter to the platform.
  /// Should be listened by a listener, which is able to communicate it's values to the platform.
  final StreamController<int> _searchResultIndexRequestStream = StreamController<int>();

  TextEditingController get searchFieldController => _searchFieldController;
  ValueListenable<int> get searchResultSize => _searchResultSize;
  ValueListenable<int> get searchResultIndex => _searchResultIndex;

  void dispose() {
    _searchResultIndexRequestStream.close();

    _searchFieldController.dispose();
    _searchResultSize.dispose();
    _searchResultIndex.dispose();
  }

  void requestSearchResultIndex(int index) {
    _searchResultIndexRequestStream.sink.add(min(max(index, 1), _searchResultSize.value));
  }

  void requestPrevSearchResult() {
    _searchResultIndexRequestStream.sink.add(max(_searchResultIndex.value - 1, 1));
  }

  void requestNextSearchResult() {
    _searchResultIndexRequestStream.sink.add(min(_searchResultIndex.value + 1, _searchResultSize.value));
  }
}

class FlutterNativePdfViewer extends StatefulWidget {
  /// This is used in the platform side to register the view.
  static const _viewType = 'flutter_native_pdf_viewer';

  /// Path to the PDF file, which can be accessed by the platform.
  final String path;

  /// Optional search controller for searching within the PDF document.
  final FlutterNativePdfViewerSearchController? searchController;

  /// Create a new FlutterNativePDFViewer widget, which allows to view a PDF at given `path`,
  /// using the native PDF viewer on iOS devices.
  const FlutterNativePdfViewer({
    super.key,
    required this.path,
    this.searchController,
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
  State<FlutterNativePdfViewer> createState() => _FlutterNativePdfViewerState();
}

class _FlutterNativePdfViewerState extends State<FlutterNativePdfViewer> {
  MethodChannel? _channel;

  String? _prevSearchQuery;

  @override
  void initState() {
    super.initState();

    widget.searchController?.searchFieldController.addListener(_searchFieldListener);

    _sendSearchResultIndexRequestsToPlatform();
  }

  @override
  void dispose() {
    super.dispose();

    widget.searchController?.searchFieldController.removeListener(_searchFieldListener);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call) {
      case MethodCall(:final method, arguments: final int resultSize) when method == 'searchResultSize':
        // Store provided platform search result size.
        widget.searchController?._searchResultSize.value = resultSize;
      case MethodCall(:final method, arguments: final int index) when method == 'searchResultIndex':
        // Store provided platform search result index.
        widget.searchController?._searchResultIndex.value = index;
    }
  }

  void _searchFieldListener() {
    final channel = _channel;
    if (channel == null) {
      return;
    }

    // Avoid duplicate search queries.
    final searchQuery = widget.searchController?.searchFieldController.text;
    if (searchQuery == _prevSearchQuery) {
      return;
    }
    _prevSearchQuery = searchQuery;

    if (searchQuery == null || searchQuery.isEmpty) {
      widget.searchController?._searchResultSize.value = 0;
      return;
    }

    channel.invokeMethod('search', searchQuery);
  }

  Future<void> _sendSearchResultIndexRequestsToPlatform() async {
    final searchController = widget.searchController;
    if (searchController == null) {
      return;
    }

    await for (final index in searchController._searchResultIndexRequestStream.stream) {
      final channel = _channel;
      if (channel == null) {
        return;
      }

      // Request a new search result index.
      channel.invokeMethod('requestSearchResultIndex', index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(
        onPlatformViewCreated: (id) {
          // A method channel is only required if a searchController is given.
          if (widget.searchController == null) return;
          _channel = MethodChannel('flutter_native_pdf_viewer_search_$id')..setMethodCallHandler(_methodCallHandler);
        },
        viewType: FlutterNativePdfViewer._viewType,
        creationParams: {'path': widget.path},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Text(
        'Android doesn\'t provide an in-App native PDF viewer. Please use the static openPdf method on Android devices.',
      );
    }
  }
}

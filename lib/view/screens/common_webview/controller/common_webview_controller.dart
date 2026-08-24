import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommonWebviewController extends GetxController {
  String? title;
  String? url;

  late WebViewController webViewController;

  double progress = 0.0;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      title = Get.arguments['title'];
      url = Get.arguments['url'];
    }
    loadWebView();
  }

  void loadWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (final int progress) {
            this.progress = progress / 100;
            update();
          },
          onPageFinished: (final String url) {
            progress = 0.0;
            update();
          },
        ),
      )
      ..loadRequest(Uri.parse(url ?? ''));
  }
}

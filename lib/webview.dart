import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnnouncementWebView extends StatefulWidget {
  AnnouncementWebView({super.key, required this.htmlString});
  var htmlString;
  @override
  State<AnnouncementWebView> createState() => _AnnouncementWebViewState();
}

class _AnnouncementWebViewState extends State<AnnouncementWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()..loadHtmlString(widget.htmlString);
    controller.enableZoom(true);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Announcement"),
      ),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}

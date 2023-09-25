// ignore_for_file: unused_local_variable, no_leading_underscores_for_local_identifiers

import 'package:drortho/utilities/loadingWrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../components/searchcomponent.dart';
import '../providers/homeProvider.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final Map args = (ModalRoute.of(context)!.settings.arguments ?? {}) as Map;
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final WebViewController _controller =
        WebViewController.fromPlatformCreationParams(
            const PlatformWebViewControllerCreationParams());

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          homeProvider.showLoader();
        },
        onPageFinished: (onPageFinished) {
          homeProvider.hideLoader();
          _controller.runJavaScript(
              '(function(){const headers = document.getElementsByTagName("header");const topBar = document.getElementById("top-bar-wrap"); const footers = document.getElementsByTagName("footer");for (const header of headers) {   header.style.display="none";}topBar.style.display="none";for (const footer of footers) {footer.style.display="none";}}())');
        },
      ))
      ..loadRequest(Uri.parse(args["url"]));

    return LoadingWrapper(
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SearchComponent(
              isBackEnabled: true,
            ),
            Expanded(
              child: WebViewWidget(
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

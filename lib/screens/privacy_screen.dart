import 'package:fieldmanager_hrms_flutter/utils/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String? privacyPolicyUrl = '';
  late WebViewController _webViewController ;
  ValueNotifier<int> loadingPercentage = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _webViewController = WebViewController();
    var appSettings = await apiRepo.getAppSettings();
    if (appSettings != null) {
      privacyPolicyUrl = appSettings.privacyPolicyUrl;
      debugPrint("privacy policy url $privacyPolicyUrl");
      sharedHelper.setAppSettings(appSettings);

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              debugPrint("On page started url : $url");
              setState(() {
                loadingPercentage.value = 0;
              });
            },
            onProgress: (progress) {
              debugPrint("Page progress : $progress");
              setState(() {
                loadingPercentage.value = progress;
              });
            },
            onPageFinished: (url) {
              debugPrint("On Page finished Url : $url");
              setState(() {
                loadingPercentage.value = 100;
              });
            },
            onNavigationRequest: (navigationRequest) {
              // final String host = Uri.parse(navigationRequest.url).host;
              // if (host.contains("youtube.com")) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text("Navigation to $host is blocked")));
              //   return NavigationDecision.prevent;
              // } else {
                return NavigationDecision.navigate;
              // }
            },
          )
      )
      ..loadRequest(
          Uri.parse(privacyPolicyUrl??'')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, language!.lblPrivacyPolicy),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: WebViewWidget(
              controller: _webViewController,
            ),
          ),
          if (loadingPercentage.value < 100)
            ValueListenableBuilder(
                valueListenable: loadingPercentage,
                builder: (_,percentage,child) {
                  return Center(
                    child: CircularProgressIndicator(
                      // The circular progress indicator is used to display the circular progress in the center of the screen with the value of the loading of page progress .
                      value: percentage / 100.0,
                    ),
                  );
                }
            ),
        ],
      ),
    );
  }
}



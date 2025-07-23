import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'notification_handler.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final firebaseToken = await messaging.getToken();

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen(firebaseMessagingBackgroundHandler);
  runApp(WebViewPage());
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>{
  var mainThemeColor = 0xff26A2FC;
  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  double progress = 0;
  var urlController = TextEditingController();
  var initialURL = 'https://www.castroelectronica.pt/';
  var isLoading = true;
  @override
  void initState() {

    super.initState();
    refreshController = PullToRefreshController(
      onRefresh: () => webViewController!.reload(),
      settings: PullToRefreshSettings(
        color: Colors.white,
        backgroundColor: Color(mainThemeColor),

      )
    );

  }

  Future<bool> _goBack(BuildContext context) async {
    if(await webViewController!.canGoBack()){
      webViewController!.goBack();
      return Future.value(false);
    }else{
      SystemNavigator.pop();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Castro Eletrónica',
      debugShowCheckedModeBanner: false,
      home: SafeArea(
          child: Scaffold(
          body: WillPopScope(
            onWillPop: () => _goBack(context),
            child:  Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
            children: [
            InAppWebView(
                onLoadStart: (controller, uri) => {

                  setState(() {
                    isLoading = true;
                  })

                },
              onProgressChanged: (controller, progress)  {
                  if (progress == 100){
                    refreshController!.endRefreshing();
                  }
                  setState(() {
                     this.progress = progress / 100;
                  });
              } ,
                pullToRefreshController: refreshController,
                onLoadStop: (controller, uri) => {
                  setState(() {
                    isLoading = false;
                  }),
                  refreshController!.endRefreshing(),
                  FlutterNativeSplash.remove()
                } ,
                initialUrlRequest: URLRequest(url: WebUri(initialURL)),
                onWebViewCreated: (controller) => webViewController = controller,
              ),
              Visibility(
                  visible: isLoading,
                  child:
              CircularProgressIndicator(
                value: progress,
                valueColor:  AlwaysStoppedAnimation(Color(mainThemeColor)),
              )
              )

          ]
            ),
        )
        ],
      )
          )
      )
    )
    );
  }

}
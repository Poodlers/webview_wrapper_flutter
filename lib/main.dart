import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  print('Token : $firebaseToken' );

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
 WebViewController? webViewController;
 final websiteURL = "https://www.castroelectronica.pt";
 @override
 void initState(){
   super.initState();
   webViewController = WebViewController()
   ..setJavaScriptMode(JavaScriptMode.unrestricted)
   ..setNavigationDelegate(NavigationDelegate(
     onProgress: (int progress) {
       // Update loading bar.
     },
     onPageStarted: (String url) {},
     onPageFinished: (String url) {
       //remove o splash screen
       FlutterNativeSplash.remove();
     },
     onHttpError: (HttpResponseError error) {},
     onWebResourceError: (WebResourceError error) {},
     onNavigationRequest: (NavigationRequest request) {
       return NavigationDecision.navigate;
     },
   ))
   ..loadRequest(Uri.parse(websiteURL));
   //remove splash screen when theres no internet
   Future.delayed(Duration(seconds: 30), () {
     FlutterNativeSplash.remove();
   });

 }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Castro Eletrónica',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: WebViewWidget(
            controller: webViewController!,
          ),
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/upload_viewmodel.dart';
import 'views/login_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
  await _initializeFCM(); // FCM başlat
}

//  FCM kurulum (token kaydı yapılmaz)
Future<void> _initializeFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Android 13+ için izin iste
  NotificationSettings settings = await messaging.requestPermission();
  print(' Bildirim izni durumu: ${settings.authorizationStatus}');

  // Topic aboneliği 
  await messaging.subscribeToTopic("warship_alert");

  // Bildirim geldiğinde göster
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final title = message.notification!.title ?? "Bildirim";
      final body = message.notification!.body ?? "İçerik yok";

      if (navigatorKey.currentState?.context != null) {
        showDialog(
          context: navigatorKey.currentState!.context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                child: const Text("Tamam"),
                onPressed: () => Navigator.pop(navigatorKey.currentState!.context),
              )
            ],
          ),
        );
      } else {
        print(" $title - $body");
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UploadViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Ship Detection AI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const LoginView(),
      ),
    );
  }
}

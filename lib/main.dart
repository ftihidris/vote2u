import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'screen/auth/login_page.dart';
import 'screen/splashscreen_page.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuthService().initNotifications();
  runApp(const Vote2U());
}

class Vote2U extends StatelessWidget {
  const Vote2U({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote2U',
      initialRoute: 'HomePage',
      theme: ThemeData(
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vote2u/firebase/firebase_options.dart';
import 'package:vote2u/screen/login_page.dart';
import 'package:vote2u/screen/splashscreen_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
          '/login': (context) =>  const LoginPage(), 
      },
    );
  }
}

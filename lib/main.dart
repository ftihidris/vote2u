import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_options.dart';
import 'screen/auth/login_page.dart';
import 'screen/splashscreen_page.dart';
import 'package:vote2u_admin/firebase/firebase_auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Vote2uAdmin());
}

class Vote2uAdmin extends StatelessWidget {
  const Vote2uAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => FirebaseAuthService(),
        ),
        StreamProvider(
          create: (context) => context.read<FirebaseAuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote2U Admin',
      theme: ThemeData(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Ensure this route exists in the routes map
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        // Add other routes here
      },
    );
  }
}

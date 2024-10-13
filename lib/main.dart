import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:homehunt/admin/admin_home.dart';
import 'package:homehunt/admin/admin_status.dart';
import 'package:homehunt/auth/admin_login_only.dart';
import 'package:homehunt/auth/login_or_register.dart';
import 'package:homehunt/components/bottompagenav.dart';
import 'package:homehunt/firebase_options.dart';
import 'package:homehunt/pages/home.dart';
import 'package:homehunt/pages/onboarding.dart';
import 'package:homehunt/pages/registerpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  Onboard(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const Home(),
        '/bottomnav': (context) => const Bottompagenav(),
        '/admin_login': (context) => const AdminLoginOnly(),
        '/admin_home': (context) => const AdminDashboard(),
      },
    );
  }
}

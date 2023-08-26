import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/views/auth/auth_page.dart';
import 'package:flutter_app/views/auth/login_page.dart';
import 'package:flutter_app/views/auth/register_page.dart';
import 'package:flutter_app/views/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MyApp());
  } catch (error) {
    print("Error initializing Firebase: $error");
    // Handle the error gracefully, show an error screen, or take any other appropriate action.
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'Insightful',
      routes: {
        'Insightful': (context) => AuthScreen(),
        'register': (context) => RegisterScreen(),
        'login': (context) => LoginScreen(),
        'home': (context) => HomePageScreen(),
      },
    );
  }
}

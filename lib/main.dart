import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tulpar_chat_app/firebase_options.dart';
import 'package:tulpar_chat_app/helper/helper_functions.dart';
import 'package:tulpar_chat_app/pages/home_page.dart';
import 'package:tulpar_chat_app/shared/constants.dart';
import 'pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  void getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        _isSignedIn = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LightChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Constants().primaryColor,
          secondaryHeaderColor: Constants().secondaryColor,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
          scaffoldBackgroundColor: const Color(0xff272829)),
      home: _isSignedIn ? const HomePage() : const LoginPage(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './screen/register_page.dart';
import './screen/signin_page.dart';
import './screen/welcome.dart';
import './screen/chat.dart';
import './screen/users.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter ChatApp',
        initialRoute: WelcomePage.id,
        routes: {
          RegisterPage.id: (context) => RegisterPage(),
          SignInPage.id: (context) => SignInPage(),
          WelcomePage.id: (context) => WelcomePage(),
          ChatPage.id: (context) => ChatPage(),
          UsersPage.id: (context) => UsersPage(),
        });
  }
}

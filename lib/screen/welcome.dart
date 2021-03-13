import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';

import './register_page.dart';
import './signin_page.dart';

class WelcomePage extends StatelessWidget {
  static const String id = 'welcome_screen';
  final String title = 'ようこそ！';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: SignInButtonBuilder(
              icon: Icons.person_add,
              backgroundColor: Colors.indigo,
              text: '登録',
              onPressed: () =>
                Navigator.pushNamed(context, RegisterPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          ),
          Container(
            child: SignInButtonBuilder(
              icon: Icons.verified_user,
              backgroundColor: Colors.deepOrange,
              text: 'ログイン',
              onPressed: () =>
                  Navigator.pushNamed(context, SignInPage.id),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
          )
        ],
      ),
    );
  }
}
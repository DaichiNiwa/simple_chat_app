import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './chat.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User _me;

class UsersPage extends StatefulWidget {
  static const String id = 'users_screen';
  final String title = 'ユーザー一覧';

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();

    _me = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              })
        ],
        title: Text(widget.title),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[UserStream()],
        ),
      ),
    );
  }
}

class UserStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('users')
          .where('email', isNotEqualTo: _me.email)
          .snapshots(), // TODO: 自分を除外する
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final users = snapshot.data.docs;
        List<UserLine> userLines = [];
        for (var user in users) {
          final Map<String, dynamic> doc = user.data();
          final userName = doc['name'];
          final userEmail = doc['email'];

          final userLine = UserLine(
            name: userName,
            email: userEmail,
          );

          userLines.add(userLine);
        }
        return Expanded(
            child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: userLines,
        ));
      },
    );
  }
}

class UserLine extends StatelessWidget {
  final String name;
  final String email;

  UserLine({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: new BoxDecoration(
              border: new Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey))),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
              ),
              Text(
                name,
                style: TextStyle(color: Colors.black, fontSize: 18.0),
              ),
            ],
          )),
      onTap: () {
        Navigator.pushNamed(context, ChatPage.id, arguments: UsersArguments(
            name: name,
            email: email
        ));
      },
    );
  }
}

class UsersArguments {
  UsersArguments({this.name, this.email});

  final String name;
  final String email;
}


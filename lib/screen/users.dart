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
          .snapshots(),
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
          final userId = doc['user_id'];
          final userName = doc['name'];

          final userLine = UserLine(
            userId: userId,
            name: userName,
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
  final int userId;
  final String name;

  UserLine({this.userId, this.name});

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
      onTap: () async {
        int _meUserId = await fetchMeUserId();
        Navigator.pushNamed(context, ChatPage.id, arguments: UsersArguments(
            meUserId: _meUserId,
            partnerUserId: userId,
            partnerName: name
        ));
      },
    );
  }

  Future<int> fetchMeUserId() async {
    int userId;
    await _db
        .collection('users')
        .where('email', isEqualTo: _me.email)
        .limit(1)
        .get()
        .then((QuerySnapshot querySnapshot) {
      userId = querySnapshot.docs.first.get('user_id');
    });

    return userId;
  }
}

class UsersArguments {
  UsersArguments({this.meUserId, this.partnerUserId, this.partnerName});

  final int meUserId;
  final int partnerUserId;
  final String partnerName;
}


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './users.dart';

final _db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User _me;

class ChatPage extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageTextController = TextEditingController();
  String messageText;

  @override
  void initState() {
    super.initState();

    _me = _auth.currentUser;
  }
  
  @override
  Widget build(BuildContext context) {
    final UsersArguments arguments = ModalRoute.of(context).settings.arguments;
    final _meUserId = arguments.meUserId;
    final roomName =
        getRoomName(meUserId: _meUserId, partnerUserId: arguments.partnerUserId);

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
        title: Text(arguments.partnerName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
              meUserId: _meUserId,
              roomName: roomName,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        hintText: 'ここに入力して下さい。',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _db
                          .collection('rooms')
                          .doc('roomNames')
                          .collection(roomName)
                          .add({
                        'text': messageText,
                        'sender_id': _meUserId,
                        'time': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      '送信',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String getRoomName({int meUserId, int partnerUserId}) {
    if (meUserId > partnerUserId) {
      return '$meUserId _ $partnerUserId';
    }

    return '$partnerUserId _ $meUserId';
  }
}

class MessageStream extends StatelessWidget {
  int meUserId;
  String roomName;

  MessageStream({this.meUserId, this.roomName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('rooms')
          .doc('roomNames')
          .collection(roomName)
          .orderBy('time', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.docs;
        List<MessageLine> messageLines = [];
        for (var message in messages) {
          final Map<String, dynamic> doc = message.data();
          final messageText = doc['text'];
          final messageSenderId = doc['sender_id'];

          final messageLine = MessageLine(
            text: messageText,
            isMine: meUserId == messageSenderId,
          );

          messageLines.add(messageLine);
        }
        return Expanded(
            child: ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          children: messageLines,
        ));
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  final String text;
  final bool isMine;

  MessageLine({this.text, this.isMine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: isMine
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMine ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

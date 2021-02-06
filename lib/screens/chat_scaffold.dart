import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/components/chat_screen.dart';
import 'package:flash_chat/screens/users_screen.dart';
import 'package:flutter/material.dart';

class ChatScaffold extends StatelessWidget {
  final DocumentSnapshot snap;
  ChatScaffold(this.snap);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snap.data()['name']),
        actions: [
          FlatButton(
            child: Text(
              'USERS',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Users(snap)));
            },
          )
        ],
      ),
      body: ChatScreen(snap),
    );
  }
}

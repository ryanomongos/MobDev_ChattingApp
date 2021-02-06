import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;
// final firebase =
DocumentSnapshot userData;

class Conversation {
  String name;
  DocumentReference ref;
  DocumentSnapshot snap;

  Conversation({this.name = "This is a conversation", this.ref, this.snap});
}

class Profile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Center(child: Column(
            children: [
              Text('Your email: '),
              Text(_auth.currentUser.email),
              RaisedButton(
                child: Text("LOGOUT"),
                onPressed: () {
                  showLogoutDialog(context);
                },
              )
            ],
          ),
          )
        )
      );
  }

  showLogoutDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Logout"),
      content: Text("Are you sure you want to logout?"),
      actions: [
        FlatButton(
          child: Text("LOGOUT"),
          onPressed: () {
            _auth.signOut();
              Navigator.pushNamed(context, WelcomeScreen.id);
          },
        ),
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

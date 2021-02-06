import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/chat_scaffold.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
// final firebase =
DocumentSnapshot userData;

class Conversation {
  String name;
  DocumentReference ref;
  DocumentSnapshot snap;

  Conversation({this.name = "This is a conversation", this.ref, this.snap});
}

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final User user = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showAlertDialog(context);
          },
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection("users").doc("${user.uid}").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return (Text('No Data Found'));
            }
            if (snapshot.data.data()['conversations'] == null || snapshot.data.data()['conversations'].length == 0) {
              return Center(child: Text('Click "+" to start a conversation'));
            }
            List<Widget> convos = [];

            for (DocumentReference conversation
                in snapshot.data.data()['conversations']) {
              convos.add(_conversationItemBuidler(context, conversation));
            }
            print(convos);
            return ListView(children: convos);
          },
        ));
  }

  Widget _conversationItemBuidler(c, DocumentReference snap) {
    return StreamBuilder<DocumentSnapshot>(
      stream: snap.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text("No data found");
        } else {
          return ListTile(
            leading: Icon(Icons.person),
            title: Text(snapshot.data.data()['name']),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScaffold(snapshot.data)));
            },
          );
        }
      },
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Add new conversation"),
      content: new MyCustomForm(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final _formKey = GlobalKey<FormState>();

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          TextFormField(
            controller: myController,
            decoration: InputDecoration(hintText: "Chat name"),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlatButton(
                child: Text("OK", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    addNewConversation(myController.text, context);
                  }
                },
              ),
              FlatButton(
                child: Text("CANCEL", style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        ]));
  }

  Future addNewConversation(String name, BuildContext context) async {
    DocumentReference newChat = await _firestore.collection('group_chats').add({
      'name': name,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'participants': [userData.reference]
    });
    await userData.reference.update({
      'conversations': FieldValue.arrayUnion([newChat])
    });
    Navigator.of(context).pop();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

final _auth = FirebaseAuth.instance;
// final firebase =
DocumentSnapshot userData;

class Conversation {
  String name;
  DocumentReference ref;
  DocumentSnapshot snap;

  Conversation({this.name = "This is a conversation", this.ref, this.snap});
}

class Users extends StatefulWidget {
  final DocumentSnapshot snap;

  Users(this.snap);
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List<Conversation> chats = [];
  final User user = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users in ${widget.snap.data()['name']}"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showEmailAlertDialog(context);
        },
      ),
      body: UsersStream(widget.snap),
    );
  }

  showEmailAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Email"),
      content: new MyCustomForm(widget.snap),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class UsersStream extends StatelessWidget {
  final DocumentSnapshot snap;

  UsersStream(this.snap);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: snap.reference.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          print(snapshot.data.data()['participants'].length);
          List<Widget> contacts = [];

          for (DocumentReference doc in snapshot.data.data()['participants']) {
            contacts.add(StreamBuilder<DocumentSnapshot>(
                stream: doc.snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) {
                    return Text('No data on user found');
                  }
                  print("user: ${snapshots.data.data()}");
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(snapshots.data.data()['email']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        showDeleteAlertDialog(
                            context, snapshots.data.data()['email']);
                      },
                    ),
                  );
                }));
          }
          return ListView(children: contacts);
        }
      },
    );
  }

  showDeleteAlertDialog(BuildContext context, String email) {
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text('Remove $email? '),
      actions: [
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            deleteUser(email);
            if(email == _auth.currentUser.email){
              Navigator.of(context).pop();
              Navigator.pushNamed(context, HomeScreen.id);
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
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void deleteUser(String email) async {
    await snap.reference.firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value != null) {
        value.docs[0].reference.update({
          'conversations': FieldValue.arrayRemove([snap.reference])
        });
        snap.reference.update({
          'participants': FieldValue.arrayRemove([value.docs[0].reference])
        });
      }
    });
  }
}

class MyCustomForm extends StatefulWidget {
  final DocumentSnapshot snap;

  MyCustomForm(this.snap);
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
            decoration: InputDecoration(hintText: "Enter email"),
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
                    addNewUser(myController.text, context);
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

  void addNewUser(String email, BuildContext context) async {
    await widget.snap.reference.firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value != null) {
        if (widget.snap
            .data()['participants']
            .contains(value.docs[0].reference)) {
          print("user already exists");
          showUserIsAlreadyMemberDialog(context, email);
        }else{
          value.docs[0].reference.update({
            'conversations': FieldValue.arrayUnion([widget.snap.reference])
          });
          widget.snap.reference.update({
            'participants': FieldValue.arrayUnion([value.docs[0].reference])
          });
          Navigator.of(context).pop();
        }
      } else {
        showUserNotFoundDialog(context, email);
      }
    }).catchError((e) {
      print("user not found");
      showUserNotFoundDialog(context, email);
    });
  }

  showUserNotFoundDialog(BuildContext context, String email) {
    AlertDialog alert = AlertDialog(
      title: Text("Woops."),
      content: Text('User $email was not found.'),
      actions: [
        FlatButton(
          child: Text("OK"),
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

  showUserIsAlreadyMemberDialog(BuildContext context, String email) {
    AlertDialog alert = AlertDialog(
      title: Text("Woops."),
      content: Text('User $email is already a member of this chat.'),
      actions: [
        FlatButton(
          child: Text("OK"),
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

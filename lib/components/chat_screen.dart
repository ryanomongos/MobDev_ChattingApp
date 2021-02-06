import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final DocumentSnapshot chat;
  ChatScreen(this.chat);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final username = _auth.currentUser;
      if (username != null) {
        loggedInUser = username;
      } else {
        print("Current user is unavailable.");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MessagesStream(widget.chat),
        Container(
          decoration: kMessageContainerDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: messageTextController,
                  onChanged: (value) {
                    messageText = value;
                  },
                  decoration: kMessageTextFieldDecoration,
                ),
              ),
              FlatButton(
                onPressed: () {
                  messageTextController.clear();
                  widget.chat.reference.collection('messages').add({
                    'text': messageText,
                    'sender': loggedInUser.email,
                    'createdAt': DateTime.now(),
                  });
                },
                child: Text(
                  'Send',
                  style: kSendButtonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessagesStream extends StatelessWidget {
  final DocumentSnapshot snap;

  MessagesStream(this.snap);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: snap.reference.collection('messages').orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message.get('text');
            final messageSender = message.get('sender');

            final currentUser = loggedInUser.email;

            final messageBubble = MessageBubble(
              text: messageText,
              sender: messageSender,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text('$text',
                  style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 15.0)),
            ),
          ),
        ],
      ),
    );
  }
}

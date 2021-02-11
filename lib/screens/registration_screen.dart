import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flash_chat/components/roundedButton.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


final _firestore = FirebaseFirestore.instance;

class RegistrationScreen extends StatefulWidget {

  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  String _userEmail;
  String _userPassword;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 200.0,
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),

              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _userEmail = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextFormField(
                key: ValueKey('password'),
                validator: (value) {
                  return (value.isEmpty || value.length < 7)
                      ? 'Password must be at least 7 characters long'
                      : null;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  _userPassword = value;
                  },
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {

                      await _auth.createUserWithEmailAndPassword(
                        email: _userEmail,
                        password: _userPassword,
                      ).then((value){
                        _firestore.collection('users').doc(_auth.currentUser.uid).set({
                          'email': _userEmail,
                          'conversations': [],
                        });
                        Navigator.pushNamed(context, HomeScreen.id);
                      });
                      setState(() {
                        showSpinner = false;
                      });
                    }catch (e) {
                      print(e);
                    }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

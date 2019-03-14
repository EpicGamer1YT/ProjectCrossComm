import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';
import 'package:projectcrosscomm/ui/sign_in.dart';

class SignUp extends StatefulWidget {
  static final String routeName = "/signUp";
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SignUpState();
  }
}

class SignUpState extends State<SignUp>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  var _formKey = GlobalKey<FormState>();
  String _dispName = "";
  TextEditingController dispName = new TextEditingController();
  String _email = "";
  TextEditingController email = new TextEditingController();
  String _pass1 = "";
  TextEditingController pass1 = new TextEditingController();
  String _pass2 = "";
  TextEditingController pass2 = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(title: new Text("Welcome to ProjectCrossComm!"),),
      body: new ListView(
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(padding: EdgeInsets.all(25.0)),
              new Container(
                color: Colors.grey,
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                child: new Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Padding(padding: EdgeInsets.all(5.0)),
                      DisplayField(),
                      new Padding(padding: EdgeInsets.all(5.0)),
                      EmailField(),
                      new Padding(padding: EdgeInsets.all(5.0)),
                      PassField(),
                      new Padding(padding: EdgeInsets.all(5.0)),
                      PassVerField(),
                      new Padding(padding: EdgeInsets.all(5.0)),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new RaisedButton(onPressed: SignUp, child: new Text("Sign Up", style: Theme.of(context).textTheme.title,),),
                          new Padding(padding: EdgeInsets.all(30.0)),
                          new RaisedButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => SignIn(
                                )),);
                          },
                            child: new Text("Sign In", style: Theme.of(context).textTheme.title,),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              new Padding(padding: EdgeInsets.all(5.0)),
              new GoogleSignInButton(onPressed: _handleSignIn, darkMode: true,)
            ],
          )
        ],
      ),
    );
  }
  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseDatabase db = FirebaseDatabase();

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      _auth.signInWithCredential(credential).then((FirebaseUser user) {
        print("signed in " + user.displayName);
        db.reference().child("users").child(user.uid).child("name").set(user.displayName);
        db.reference().child("users").child(user.uid).child("email").set(user.email);
        db.reference().child("users").child(user.uid).child("uid").set(user.uid);
        db.reference().child("users").child(user.uid).child("imageUrl").set(user.photoUrl);
        db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("name").set(user.displayName);
        db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("email").set(user.email);
        db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("uid").set(user.uid);
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => ChatsHome(

            )),);
        return user;
      });
    } on PlatformException catch (e) {
      print(e);
    }
    return null;

  }
  void SignUp() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        _auth.createUserWithEmailAndPassword(email: _email, password: _pass1).then((FirebaseUser user) async {
          final FirebaseDatabase db = FirebaseDatabase();
          UserUpdateInfo info = new UserUpdateInfo();
          info.displayName = _dispName;
          user.updateProfile(info);
          await user.reload();
          user = await  _auth.currentUser();
          db.reference().child("users").child(user.uid).child("name").set(user.displayName);
          db.reference().child("users").child(user.uid).child("email").set(user.email);
          db.reference().child("users").child(user.uid).child("uid").set(user.uid);
          db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("name").set(user.displayName);
          db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("email").set(user.email);
          db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("uid").set(user.uid);
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => ChatsHome(
              )),);
        });
      } on PlatformException catch (e) {
        print(e);
      }
    }
  }
  TextFormField DisplayField() {
    return TextFormField(
      controller: dispName,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter a username');
        }
      },
      onSaved: (value) {
        _dispName = value;
      },
      decoration: InputDecoration(
          hintText: "Username",
          icon: Icon(Icons.account_circle),
          fillColor: Colors.grey
      ),
    );
  }
  TextFormField EmailField() {
    return TextFormField(
      controller: email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter an email');
        }
      },
      onSaved: (value) {
        _email = value;
      },
      decoration: InputDecoration(
          hintText: "Email",
          icon: Icon(Icons.email),
          fillColor: Colors.grey
      ),
    );
  }
  TextFormField PassField() {
    return TextFormField(
      controller: pass1,
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter a password');
        }
        if (pass1.text != pass2.text) {
          return ('Passwords do not match');
        }
      },
      onSaved: (value) {
        _pass1 = value;
      },
      decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(Icons.vpn_key),
          fillColor: Colors.grey
      ),
    );
  }
  TextFormField PassVerField() {
    return TextFormField(
      controller: pass2,
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter a password');
        }
        if (pass2.text != pass1.text) {
          return ('Passwords do not match');
        }
      },
      onSaved: (value) {
        _pass2 = value;
      },
      decoration: InputDecoration(
          hintText: "Confirm Password",
          icon: Icon(Icons.vpn_key),
          fillColor: Colors.grey
      ),
    );
  }
}
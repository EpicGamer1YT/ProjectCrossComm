import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';
import 'package:projectcrosscomm/ui/sign_up.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';

class SignIn extends StatefulWidget {
  static final String routeName = "/signIn";
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new SignInState();
  }

}

class SignInState extends State<SignIn>{
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool torf = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new FutureBuilder(
      future: _getUser(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else if (snapshot.hasData) {
              return new Scaffold(
                appBar: AppBar(title: new Text("Welcome to Lingua!"),),
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
                                EmailField(),
                                new Padding(padding: EdgeInsets.all(5.0)),
                                PasswordField(),
                                new Padding(padding: EdgeInsets.all(5.0)),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new RaisedButton(onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => SignUp(
                                          )),);
                                    },
                                      child: new Text("Sign Up", style: Theme.of(context).textTheme.title,),),
                                    new Padding(padding: EdgeInsets.all(30.0)),
                                    new RaisedButton(onPressed: SignIn, child: new Text("Sign In", style: Theme.of(context).textTheme.title,),),
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
            } else {
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text("Loading..."),
                ),
                backgroundColor: Colors.black,
                body: _buildForm(snapshot),
              );
            }
        }
      });
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseDatabase db = FirebaseDatabase();

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
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
  }
  void SignIn() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        _auth.signInWithEmailAndPassword(email: _email, password: _password)
            .then((FirebaseUser user) {
          final FirebaseDatabase db = FirebaseDatabase();
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

  TextFormField PasswordField() {
    return TextFormField(
      controller: password,
      keyboardType: TextInputType.text,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return ('Please enter a password');
        }
      },
      onSaved: (value) {
        _password = value;
      },
      decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(Icons.vpn_key),
          fillColor: Colors.grey
      ),
    );
  }
  Future<bool> _getUser() async {
    String version = await getVersion();
    FirebaseUser user = await _auth.currentUser();
    print("$user");
    if (user != null) {
      torf = true;
      final FirebaseDatabase db = FirebaseDatabase();
      DataSnapshot versionCodeData = await db.reference().child(
          Platform.isIOS ? "versionApple" : "versionAndroid").once();
      if (versionCodeData.value.toString() != version) {
        int vVal = int.parse(versionCodeData.value.toString());
        if (vVal > int.parse(version)) {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: new Text("Please update the app"),
                  content: new Text(Platform.isIOS
                      ? "Please install the latest version of the app by clicking below"
                      : "Please download the latest version of the app by clicking below"),
                  actions: <Widget>[
                    new FlatButton(onPressed: () {
                      LaunchReview.launch();
                    }, child: new Text("Click here to update the app!"))
                  ],

                );
              }
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatsHome()),
        );
      }
      return true;
    } else {
      torf = false;
      return false;
    }
    return false;
  }
  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.buildNumber;
    print(version);
    return version;
  }
  Widget _buildForm(AsyncSnapshot<bool> snapshot) {
    var action =
    snapshot.connectionState != ConnectionState.none && !snapshot.hasData
        ? new Stack(
      alignment: FractionalOffset.center,
      children: <Widget>[
        new CircularProgressIndicator(
          backgroundColor: Colors.red,
        ),
      ],
    )
        : null;

    return new ListView(
      padding: const EdgeInsets.all(15.0),
      children: <Widget>[
        new ListTile(
          title: new TextField(),
        ),
        new ListTile(
          title: new TextField(obscureText: true),
        ),
        new Center(child: action)
      ],
    );
  }

}


import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart' as api;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';
import 'package:projectcrosscomm/ui/custom/chat_bubble.dart';

class ChatsView extends StatefulWidget {
  ChatsView({this.oUid, this.natUid, this.uidChat, this.accepted});
  final String uidChat;
  final String natUid;
  final String oUid;
  final bool accepted;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChatsViewState();
  }
}

class ChatsViewState extends State<ChatsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String name = "";
    // TODO: implement build
    return new WillPopScope(
      onWillPop: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatsHome()),
        );
      },
      child: new Scaffold(
        appBar: new AppBar(
          title: Text(name),
          leading: new IconButton(
              icon: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatsHome()),
                );
              }),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(child: new ListView(
                children: <Widget>[
                  new Bubble(message: "GHJGDSHGFHGFHGHSGDHKJSFKGJDWFWGJHLDWHSGK", time: "hh", isMe: true, delivered: true, userInit: "T",),
                ],
              ),),
              new ClipRRect(
                borderRadius: new BorderRadius.circular(30.0),
                child: new Container(
                  color: Colors.grey,
                  child: new Row(children: <Widget>[
                    new Padding(padding: EdgeInsets.all(10.0)),
                    new Expanded(
                      child: new TextField(
                        decoration: InputDecoration(fillColor: Colors.grey, hintText: "Type chat..."),
                      ),
                    ),
                    new IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          print("HI");
                        }),
                  ]),
                ),
              ),
              Platform.isIOS ? new Padding(padding: EdgeInsets.all(30)) : new Container(),
            ],
          ),
        )
        ),
    );
  }

  void pushChat(RSAPrivateKey privKey) {

  }
}

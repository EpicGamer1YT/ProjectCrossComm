import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';

class ChatsView extends StatefulWidget {
  ChatsView({this.newChat, this.natUid, this.oUid});

  final bool newChat;
  final String natUid;
  final String oUid;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChatsViewState();
  }
}

class ChatsViewState extends State<ChatsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

      ),
    );
  }
}

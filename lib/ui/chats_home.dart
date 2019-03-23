import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as api;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:projectcrosscomm/ui/chat_view.dart';
import 'package:projectcrosscomm/ui/custom/rsa_helper.dart';
import 'package:projectcrosscomm/ui/new_chat.dart';
import 'package:projectcrosscomm/ui/sign_in.dart';

class ChatsHome extends StatefulWidget {
  static final String routeName = "/chatsHome";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChatsHomeState();
  }
}

class ChatsHomeState extends State<ChatsHome> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool acceptedMe = false;
  bool oAcceptNM = true;
  String chatsUID = "";
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new FutureBuilder(
      future: getChats(),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snap) {
        switch (snap.connectionState) {
          default:
            if(snap.hasError) {
              return new Text('Error: ${snap.error}');
            } else if (snap.hasData) {
              return new WillPopScope(
                onWillPop: () {
                  _showDialog();
                },
                child: new Scaffold(
                  appBar: new AppBar(
                    title: new Text("Your Chats"),
                    actions: <Widget>[
                      new IconButton(
                          icon: Icon(Icons.account_circle),
                          onPressed: () {
                            _auth.signOut();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          })
                    ],
                    leading: new IconButton(icon: Icon(Icons.close), onPressed: () {
                      _showDialog();
                    }),
                  ),
                  body: new Container(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(child: new ListView(
                            children: snap.data,
                          )),

                        ],
                      )
                  ),
                  floatingActionButton: new FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewChat()),
                      );
                    },
                    child: new Icon(Icons.add),
                  ),
                ),
              );
            } else {
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text("Loading..."),
                ),
                backgroundColor: Colors.black,
                body: _buildForm(snap),
              );
            }
        }
      },
    );

  }
  Future<List<Widget>> getChats() async {
    List<Widget> listItems = [];
    listItems.add(new Padding(padding: EdgeInsets.all(5.0)));
    FirebaseUser user = await _auth.currentUser();
    FirebaseDatabase db = new FirebaseDatabase();
    DataSnapshot chats = await db.reference().child("users").child("emailConv").child(user.email.replaceAll(".", ",")).child("chats").once();
    if(chats.value != null) {
      Map<String, String> uids = Map.from(chats.value);
      List<String> oUids = uids.keys.toList();
      print(oUids);
      for(int i = 0; i < oUids.length; i++) {
        String name = "";
        String uidOrder = uids[oUids[i]] == "true" ? "${user.uid} ${oUids[i]}" : "${oUids[i]} ${user.uid}";
        chatsUID = uidOrder;
        print(uidOrder);
        bool accept = false;
        bool otherAccepted = false;
        DataSnapshot otherName = await db.reference().child("chats").child(uidOrder).child(oUids[i]).child("info").child("name").once();
        DataSnapshot accepted = await db.reference().child("chats").child(uidOrder).child("accepted").child(user.uid).once();
        DataSnapshot otherAccept = await db.reference().child("chats").child(uidOrder).child("accepted").child(oUids[i]).once();
        DataSnapshot lastMsg = await db.reference().child("chats").child(uidOrder).child(user.uid).child("messages").once();
        String msg = "";
        String msgEnc = "";
        String sender = "";
        if (lastMsg.value != null) {
          print(lastMsg.value);
          Map<String, Map<dynamic, dynamic>> msgs = Map.from(lastMsg.value);
          List<String> sorted = msgs.keys.toList()..sort();
          msgEnc = msgs[sorted[msgs.keys.toList().length -1]]["message"];
          print(msgs[msgs.keys.toList()[msgs.keys.toList().length - 1]]);
          sender = msgs[sorted[msgs.keys.toList().length -1]]["sender"];
        } else {
          msg = "No Mesages!";
        }
        accept = accepted.value == "true" ? true : false;
        otherAccepted = otherAccept.value == "true" ? true : false;
        acceptedMe = accept;
        oAcceptNM = otherAccepted;
        String priv = "";
        if (accept && otherAccepted) {
          DataSnapshot privKey = await db.reference().child("chats").child(chatsUID).child(user.uid).child("privKey").once();
          if (privKey.value != null) {
            priv = privKey.value.toString();
            print("KEY: $priv");
          }
        }

        if(otherName.value != null) {
          name = otherName.value.toString();
          RsaKeyHelper helper = new RsaKeyHelper();
          RSAPrivateKey key;
          if (priv.isNotEmpty) {
            key = helper.parsePrivateKeyFromPem(priv);
          }
          if (msgEnc.isNotEmpty && sender.isNotEmpty && key != null && otherAccepted && accept) {
            var cipher = new RSAEngine()..init( false, new api.PrivateKeyParameter<RSAPrivateKey>(key));
            String message = String.fromCharCodes(cipher.process(new Uint8List.fromList(msgEnc.codeUnits)));
            print("HI $message");
            print(sender);
            print(user.uid);
            if (sender == user.uid) {
              msg = "Me: $message";
            } else {
              msg = "$name: $message";
            }
          } else if (accept == false) {
            msg = "Accept this chat to talk to $name";
          } else if (otherAccepted == false) {
            msg = "$name has not accepted this chat yet";
          } else {
            msg = "No messages!";
          }
          listItems.add(new ListTile(
            title: new Text(name, style: Theme.of(context).textTheme.title, textAlign: TextAlign.center,),
           subtitle: new Text(msg, style: TextStyle(color: Colors.grey.shade400, fontSize: 14.0), textAlign: TextAlign.center,),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatsView(
                  uidChat: uidOrder,
                  oUid: oUids[i],
                  accepted: accept,
                  otherAccept: otherAccepted,
                  oDisp: name,
                  natUid: user.uid,
                )),
              );
            },
          leading: new CircleAvatar(
            backgroundColor: Colors.red,
            child: Text(name[0].toUpperCase()),
          ),
          ));
          listItems.add(new Divider(color: Colors.white,));
        }

      }
      print(uids);
    }
    return listItems;
  }
  Widget _buildForm(AsyncSnapshot<List<Widget>> snapshot) {
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
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Exit App"),
          content: new Text("Are You Sure You Want to Exit?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

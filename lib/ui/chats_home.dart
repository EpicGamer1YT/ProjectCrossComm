import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:projectcrosscomm/ui/chat_view.dart';
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatsHome()),
                  );
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
                    leading: null,
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
      for(int i = 0; i < oUids.length; i++) {
        String name = "";
        String uidOrder = uids[oUids[i]] == "true" ? "${user.uid} ${oUids[i]}" : "${oUids[i]} ${user.uid}";
        print(uidOrder);
        bool accept = false;
        DataSnapshot otherName = await db.reference().child("chats").child(uidOrder).child(oUids[i]).child("info").child("name").once();
        DataSnapshot accepted = await db.reference().child("chats").child(uidOrder).child("accepted").child(user.uid).once();
        if(accepted.value != null) {
          accepted.value == "true" ? accept = true : accept = false;
        }
        if(otherName.value != null) {
          name = otherName.value.toString();
        }
        listItems.add(new ListTile(
          title: new Text(name, style: Theme.of(context).textTheme.title,),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatsView(
                uidChat: uidOrder,
                natUid: user.uid,
                oUid: oUids[i],
                accepted: accept,
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
}

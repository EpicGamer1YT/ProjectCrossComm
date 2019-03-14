import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:projectcrosscomm/ui/chat_view.dart';

class NewChat extends StatefulWidget {
  static final String routeName = "/newChat";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NewChatState();
  }
}

class NewChatState extends State<NewChat> {
  bool search = false;
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text("Add a New Chat");
  List<String> names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  String _searchText = "";
  Map<String, String> name = {};
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _filter = new TextEditingController();
  List<Widget> listItems = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    listItems.add(Text(
      "HI",
      style: Theme.of(context).textTheme.title,
    ));
    return new Scaffold(
        appBar: new AppBar(title: _appBarTitle, actions: <Widget>[
          new IconButton(icon: _searchIcon, onPressed: _searchPressed)
        ]),
        body: search ? _buildList() : new ListView());
  }

  @override
  void initState() {
    // TODO: implement initState
    this._getNames();
    super.initState();
  }

  void _getNames() async {
    FirebaseDatabase db = FirebaseDatabase();
    List tempList = new List();
    DataSnapshot snap =
        await db.reference().child("users").child("emailConv").once();
    print(snap.value);
    Map<String, dynamic> values;
    if (snap.value != null) {
      values = new Map.from(snap.value);
    }
    tempList = List.from(values.keys);
    for (int i = 0; i < values.length; i++) {
      name[tempList[i]] = values[tempList[i]]["name"];
    }
    setState(() {
      names = List.from(tempList);
      filteredNames = names;
    });
  }

  NewChatState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
          search = false;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Widget _buildList() {
    if (!(_searchText.isEmpty) && search) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]
            .toLowerCase()
            .toString()
            .replaceAll(",", ".") == _searchText.toLowerCase()) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new Card(
          color: Theme.of(context).cardColor,
          child: new ListTile(
            title: Text(
              name[filteredNames[index].toString()],
              style: Theme.of(context).textTheme.title,
            ),
            subtitle: Text(
              filteredNames[index].toString().replaceAll(",", "."),
              style: Theme.of(context).textTheme.subtitle,
            ),
            onTap: () => print(filteredNames[index]),
          ),
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          onSubmitted: (value) {
            search = true;
          },
          decoration: new InputDecoration(
              icon: new Icon(Icons.search), hintText: 'Email...'),
        );
      } else {
        search = false;
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('New Chat');
        filteredNames = names;
        _filter.clear();
      }
    });
  }
  void _createChat(String email) async {
    FirebaseUser user = await _auth.currentUser();
    FirebaseDatabase db = new FirebaseDatabase();
    DataSnapshot snap = await db.reference().child("users").child("emailConv").child(email).child("uid").once();
    if (snap.value != null) {
      String uid = snap.value;
      String natUid = user.uid;
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChatsView(
            newChat: true,
            natUid: natUid,
            oUid: uid,
          )),);
    }
  }
}

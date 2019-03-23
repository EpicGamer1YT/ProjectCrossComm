import 'dart:convert';
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
import 'package:projectcrosscomm/ui/chat_view.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:encrypt/encrypt.dart';
import 'package:projectcrosscomm/ui/custom/rsa_helper.dart';


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
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    listItems.add(Text(
      "HI",
      style: Theme.of(context).textTheme.title,
    ));
    return new Scaffold(
      key: _scaffoldKey,
        appBar: new AppBar(title: _appBarTitle, actions: <Widget>[
          new IconButton(icon: _searchIcon, onPressed: _searchPressed)
        ]),
        body: search ? _buildList() : new Center(child: new Text("Press search and type the user's email", style: Theme.of(context).textTheme.title,),));
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
            onTap: () {
              _createChat(filteredNames[index].toString().replaceAll(",", "."), name[filteredNames[index].toString()]);
            },
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
  void _createChat(String email, String name) async {
    FirebaseUser user = await _auth.currentUser();
    FirebaseDatabase db = new FirebaseDatabase();
    DataSnapshot snap = await db.reference().child("users").child("emailConv").child(email.replaceAll(".", ",")).child("uid").once();
    if (snap.value != null) {
      String uid = snap.value;
      String natUid = user.uid;
     chatMake(natUid, uid, email, name);
    }
  }
  void chatMake(String natUid, String oUid, String email, String name) async {
    FirebaseUser user = await _auth.currentUser();
    FirebaseDatabase db = new FirebaseDatabase();
    DataSnapshot msgsChk = await db.reference().child("chats").child("$natUid $oUid").child(user.uid).child("messages").once();
    DataSnapshot msgsChl2 = await db.reference().child("chats").child("$oUid $natUid").child(user.uid).child("messages").once();
    DataSnapshot acceptChk = await db.reference().child("chats").child("$natUid $oUid").child("accepted").once();
    DataSnapshot acceptChk2 = await db.reference().child("chats").child("$oUid $natUid").child("accepted").once();
    bool accept1 = false;
    bool oAccept= false;
    Map<String, String> accepted;
    if (acceptChk.value != null) {
      accepted = Map.from(acceptChk.value);
      accept1 = accepted[user.uid] == "true" ? true : false;
      oAccept = accepted[oUid] == "true" ? true : false;
    } else if(acceptChk2.value != null) {
      accepted = Map.from(acceptChk2.value);
      accept1 = accepted[user.uid] == "true" ? true : false;
      oAccept = accepted[oUid] == "true" ? true : false;
    }
    if (msgsChk.value != null && (accept1|| oAccept)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsView(
          oDisp: name,
          natUid: user.uid,
          uidChat: "$natUid $oUid",
          oUid: oUid,
          accepted: accept1,
          otherAccept: oAccept,
        )),
      );
    } else if (msgsChl2.value != null && (accept1 || oAccept)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsView(
          oDisp: name,
          natUid: user.uid,
          uidChat: "$oUid $natUid",
          oUid: oUid,
          accepted: accept1,
          otherAccept: oAccept,
        )),
      );
    } else {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content: new Text("Creating Encrypted chat...")));
      var keyParams = new RSAKeyGeneratorParameters(
          new BigInt.from(65537), 2048, 5);
      var secureRandom = new FortunaRandom();
      var random = new Random.secure();
      List<int> seeds = [];
      for (int i = 0; i < 32; i++) {
        seeds.add(random.nextInt(255));
      }
      secureRandom.seed(new api.KeyParameter(new Uint8List.fromList(seeds)));

      var rngParams = new api.ParametersWithRandom(keyParams, secureRandom);
      var k = new RSAKeyGenerator();
      k.init(rngParams);
      var keyPair = k.generateKeyPair();
      RSAPrivateKey privateKey = keyPair.privateKey;
      RSAPublicKey publicKey = keyPair.publicKey;
      String pubKey = "${encodePublicKeyToPemPKCS1(publicKey)}";
      String privKey = "${encodePrivateKeyToPemPKCS1(privateKey)}";

      db.reference().child("chats").child("$natUid $oUid")
          .child(user.uid)
          .child("pubKey")
          .set(encodePublicKeyToPemPKCS1(publicKey));
      db.reference().child("chats").child("$natUid $oUid")
          .child(user.uid)
          .child("privKey")
          .set(encodePrivateKeyToPemPKCS1(privateKey));
      db.reference().child("chats").child("$natUid $oUid")
          .child("accepted")
          .child(user.uid)
          .set("true");
      db.reference().child("chats").child("$natUid $oUid")
          .child("accepted")
          .child(oUid)
          .set("false");
      db.reference().child("chats").child("$natUid $oUid").child(oUid).child(
          "info").child("email").set(email);
      db.reference().child("chats").child("$natUid $oUid").child(oUid).child(
          "info").child("name").set(name);
      db.reference().child("chats").child("$natUid $oUid").child(user.uid)
          .child("info").child("email")
          .set(user.email);
      db.reference().child("chats").child("$natUid $oUid").child(user.uid)
          .child("info").child("name")
          .set(user.displayName);
      db.reference().child("users").child("emailConv").child(
          user.email.replaceAll(".", ",")).child("chats").child(oUid).set(
          "true");
      db.reference().child("users").child("emailConv").child(
          email.replaceAll(".", ",")).child("chats").child(natUid).set("false");
      RsaKeyHelper helper = new RsaKeyHelper();
      var cipher = new RSAEngine()
        ..init(true, new api.PrivateKeyParameter<RSAPrivateKey>(
            helper.parsePrivateKeyFromPem(privKey)));
      var cipherText = cipher.process(
          new Uint8List.fromList("Woahahhhhahdhhsdah".codeUnits));
      RSAPrivateKey priv = helper.parsePrivateKeyFromPem(privKey);
      print("Encrypted: ${new String.fromCharCodes(cipherText)}");
      cipher.init(false, new api.PublicKeyParameter<RSAPublicKey>(
          helper.parsePublicKeyFromPem(pubKey)));
//    var cipher2 = new RSAEngine()..init(true, new api.PrivateKeyParameter<RSAPrivateKey>(priv));
//    var decrypt = cipher2.process(cipherText);
      //cipher.init( false, new PrivateKeyParameter(keyPair.privateKey) )
      var decrypted = cipher.process(cipherText);
//    print("decrypt2: ${new String.fromCharCodes(decrypt)}");
      print("Decrypted: ${new String.fromCharCodes(decrypted)}");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatsHome()),
      );
    }
  }
  String encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var topLevel = new ASN1Sequence();

    topLevel.add(ASN1Integer(publicKey.modulus));
    topLevel.add(ASN1Integer(publicKey.exponent));

    var dataBase64 = base64.encode(topLevel.encodedBytes);
    return "$dataBase64";
  }
  String encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {

    var topLevel = new ASN1Sequence();

    var version = ASN1Integer(BigInt.from(0));
    var modulus = ASN1Integer(privateKey.n);
    var publicExponent = ASN1Integer(privateKey.exponent);
    var privateExponent = ASN1Integer(privateKey.d);
    var p = ASN1Integer(privateKey.p);
    var q = ASN1Integer(privateKey.q);
    var dP = privateKey.d % (privateKey.p - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = privateKey.d % (privateKey.q - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = privateKey.q.modInverse(privateKey.p);
    var co = ASN1Integer(iQ);

    topLevel.add(version);
    topLevel.add(modulus);
    topLevel.add(publicExponent);
    topLevel.add(privateExponent);
    topLevel.add(p);
    topLevel.add(q);
    topLevel.add(exp1);
    topLevel.add(exp2);
    topLevel.add(co);

    var dataBase64 = base64.encode(topLevel.encodedBytes);

    return "$dataBase64";
  }
}

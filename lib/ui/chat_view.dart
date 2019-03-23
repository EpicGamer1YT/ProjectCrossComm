import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart' as api;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:projectcrosscomm/ui/chats_home.dart';
import 'package:projectcrosscomm/ui/custom/chat_bubble.dart';
import 'package:projectcrosscomm/ui/custom/rsa_helper.dart';

class ChatsView extends StatefulWidget {
  ChatsView(
      {this.oUid, this.uidChat, this.accepted, this.otherAccept, this.oDisp, this.natUid});

  final String uidChat;
  final String oUid;
  final bool accepted;
  final bool otherAccept;
  final String oDisp;
  final String natUid;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChatsViewState();
  }
}

class ChatsViewState extends State<ChatsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  TextEditingController _message = new TextEditingController();
  String uid = "";
  bool accept = false;
  bool first = true;
  bool noChat = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("UID: $uid");
    DatabaseReference query = FirebaseDatabase.instance
        .reference()
        .child("chats")
        .child(widget.uidChat).child(widget.natUid).child("messages");
    if (first) {
      accept = widget.accepted;
      first = false;
    }
    return new FutureBuilder(
      future: getKeys(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> keys) {
        switch (keys.connectionState) {
          default:
            if (keys.hasError) {
              return Text("${keys.error}");
            } else if (keys.hasData) {
              print("Here");
              print(keys.data);
              RsaKeyHelper helper = new RsaKeyHelper();
              RSAPrivateKey priv;
              RSAPublicKey natPub;
              RSAPublicKey oPub;
              if (keys.data["privKey"] != null && keys.data["natPubKey"] != null && keys.data["oPubKey"] != null) {
                priv = helper.parsePrivateKeyFromPem(keys.data["privKey"].toString());
                natPub = helper.parsePublicKeyFromPem(keys.data["natPubKey"].toString());
                oPub = helper.parsePublicKeyFromPem(keys.data["oPubKey"].toString());
              }
              return new WillPopScope(
                onWillPop: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatsHome()),
                  );
                },
                child: new Scaffold(
                    key: _key,
                    appBar: new AppBar(
                      title: Text(widget.oDisp),
                      leading: new IconButton(
                          icon: Icon(Platform.isIOS
                              ? Icons.arrow_back_ios
                              : Icons.arrow_back),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatsHome()),
                            );
                          }),
                    ),
                    body:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                              child: new FirebaseAnimatedList(
                                  query: query,
                                  controller: _scrollController,
                                  itemBuilder: (_, DataSnapshot snapshot,
                                      Animation<double> animation, int x) {
                                    var cipher = new RSAEngine()..init( false, new api.PrivateKeyParameter<RSAPrivateKey>(priv));
                                    String message = String.fromCharCodes(cipher.process(new Uint8List.fromList(snapshot.value["message"].toString().codeUnits)));
                                    String time = snapshot.value["time"];
                                    String init = widget.oDisp[0].toUpperCase();
                                    bool isMe = snapshot.value["sender"] == widget.natUid ? false : true;
                                    print("HERE");
                                    print(snapshot.value);
                                    Timer(Duration(milliseconds: 1), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
                                    return new Bubble(message: message, time: time, userInit: init, isMe: isMe, delivered: true,);
                                  })),
                          noChat
                              ? new Text(
                                  "No chats sent... Send a chat to get started!",
                                  style: Theme.of(context).textTheme.subtitle,
                                )
                              : new Container(),
                          accept
                              ? new ClipRRect(
                                  borderRadius: new BorderRadius.circular(30.0),
                                  child: new Container(
                                    color: Colors.grey,
                                    child: new Row(children: <Widget>[
                                      new Padding(
                                          padding: EdgeInsets.all(10.0)),
                                      new Expanded(
                                        child: new TextField(
                                          controller: _message,
                                          decoration: InputDecoration(
                                              fillColor: Colors.grey,
                                              hintText: "Type chat..."),
                                        ),
                                      ),
                                      new IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {
                                            pushChat(natPub, _message.text, oPub);
                                          }),
                                    ]),
                                  ),
                                )
                              : new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Center(
                                      child: new Text(
                                        "${widget.oDisp} would like to chat with you",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        new Expanded(
                                          child: new RaisedButton(
                                            onPressed: denyChat,
                                            child: Text(
                                              "Decline",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle,
                                            ),
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            color: Colors.grey,
                                          ),
                                        ),
                                        new Expanded(
                                            child: new RaisedButton(
                                          onPressed: acceptChat,
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          child: Text(
                                            "Accept",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle,
                                          ),
                                          color: Colors.blue.shade300,
                                        ))
                                      ],
                                    )
                                  ],
                                ),
                          Platform.isIOS
                              ? new Padding(padding: EdgeInsets.all(30))
                              : new Container(),
                        ],
                      ),
                    ),
              );
            } else {
              return new Scaffold(
                appBar: new AppBar(
                  title: new Text("Loading..."),
                ),
                backgroundColor: Colors.black,
                body: _buildForm(keys),
              );
            }
        }
      },
    );
  }

  Future<Map<String, dynamic>> getKeys() async {
    Map<String, dynamic> keyMap = {};
    if (widget.otherAccept && widget.accepted) {
      FirebaseDatabase database = new FirebaseDatabase();
      FirebaseUser user = await _auth.currentUser();
      uid = user.uid;
      DataSnapshot privKey = await database
          .reference()
          .child("chats")
          .child(widget.uidChat)
          .child(user.uid)
          .child("privKey")
          .once();
      DataSnapshot natPub = await database
          .reference()
          .child("chats")
          .child(widget.uidChat)
          .child(user.uid)
          .child("pubKey")
          .once();
      DataSnapshot oPub = await database
          .reference()
          .child("chats")
          .child(widget.uidChat)
          .child(widget.oUid)
          .child("pubKey")
          .once();
      if (privKey.value != null && oPub.value != null && natPub.value != null) {
        keyMap["privKey"] = privKey.value;
        keyMap["natPubKey"] = natPub.value;
        keyMap["oPubKey"] = oPub.value;
        print(oPub.value);
      }
      return keyMap;
    } else {
      return {"not": "not"};
    }
  }

  void acceptChat() async {
    FirebaseDatabase db = new FirebaseDatabase();
    FirebaseUser user = await _auth.currentUser();
    var keyParams =
        new RSAKeyGeneratorParameters(new BigInt.from(65537), 2048, 5);
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
    db
        .reference()
        .child("chats")
        .child(widget.uidChat)
        .child(user.uid)
        .child("pubKey")
        .set(encodePublicKeyToPemPKCS1(publicKey));
    db
        .reference()
        .child("chats")
        .child(widget.uidChat)
        .child(user.uid)
        .child("privKey")
        .set(encodePrivateKeyToPemPKCS1(privateKey));
    db
        .reference()
        .child("chats")
        .child(widget.uidChat)
        .child("accepted")
        .child(user.uid)
        .set("true");
    setState(() {
      accept = true;
    });
  }

  void denyChat() async {
    FirebaseDatabase db = new FirebaseDatabase();
    FirebaseUser user = await _auth.currentUser();
    db
        .reference()
        .child("users")
        .child("emailConv")
        .child(user.email.replaceAll(".", ","))
        .child("chats")
        .child(widget.oUid)
        .remove();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatsHome()),
    );
  }

  void pushChat(RSAPublicKey myPub, String message, RSAPublicKey oPub) async {
    if (message != "") {
      FirebaseDatabase db = new FirebaseDatabase();
      FirebaseUser user = await _auth.currentUser();
      if (widget.otherAccept && widget.accepted) {
        int epoch = new DateTime.now().millisecondsSinceEpoch;
        print(TimeOfDay.now());
        int hour = TimeOfDay
            .now()
            .hour;
//      int month = DateTime.now().month;
//      int day = DateTime.now().day;
//      int year = DateTime.now().year;
        if (TimeOfDay
            .now()
            .hour > 12) {
          hour = TimeOfDay
              .now()
              .hour - 12;
        }
        String time = "$hour:${TimeOfDay
            .now()
            .minute}";
        var cipher = new RSAEngine()
          ..init(true, new api.PublicKeyParameter<RSAPublicKey>(oPub));
        String oEnc = new String.fromCharCodes(
            cipher.process(new Uint8List.fromList(message.codeUnits)));
        cipher.init(true, new api.PublicKeyParameter<RSAPublicKey>(myPub));
        String myEnc = new String.fromCharCodes(
            cipher.process(new Uint8List.fromList(message.codeUnits)));
        Map<String, String> chatToAddOther = {
          "message": oEnc,
          "time": time,
          "sender": user.uid
        };
        Map<String, String> chatToAddMe = {
          "message": myEnc,
          "time": time,
          "sender": user.uid
        };
        db.reference().child("chats").child(widget.uidChat).child(widget.oUid)
            .child("messages").child("$epoch")
            .set(chatToAddOther);
        db.reference().child("chats").child(widget.uidChat).child(user.uid)
            .child("messages").child("$epoch")
            .set(chatToAddMe);
        Timer(Duration(milliseconds: 0), () => _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100, curve: Curves.ease,
            duration: const Duration(milliseconds: 300)));
        _message.value = TextEditingValue(text: "");
      } else {
        _key.currentState.showSnackBar(new SnackBar(
            content: Text(
                "You can't send chats until the other user accepts your request")));
      }
    } else {
      _key.currentState.showSnackBar(new SnackBar(
          content: Text(
              "Enter some text before you send a chat!"), duration: Duration(milliseconds:  100),));
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

  Widget _buildForm(AsyncSnapshot<Map<String, dynamic>> snapshot) {
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

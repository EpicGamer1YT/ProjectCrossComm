import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import "package:pointycastle/export.dart";
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:projectcrosscomm/ui/new_chat.dart';

class ChatsHome extends StatefulWidget {
  static final String routeName = "/chatsHome";
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new ChatsHomeState();
  }

}

class ChatsHomeState extends State<ChatsHome>{
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(title: new Text("Your Chats"), actions: <Widget>[new IconButton(icon: Icon(Icons.account_circle), onPressed: () {
        print("Settings");
      })], leading: null,),
      floatingActionButton: new FloatingActionButton(onPressed: ()  {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => NewChat(
            )),);
//        print("New Chats");
//        var keyParams = new RSAKeyGeneratorParameters(new BigInt.from(65537), 2048, 5);
//        var secureRandom = new FortunaRandom();
//        var random = new Random.secure();
//        List<int> seeds = [];
//        for (int i = 0; i < 32; i++) {
//          seeds.add(random.nextInt(255));
//        }
//        secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));
//
//        var rngParams = new ParametersWithRandom(keyParams, secureRandom);
//        var k = new RSAKeyGenerator();
//        k.init(rngParams);
//        var keyPair = k.generateKeyPair();
//        var cipher = new RSAEngine()..init( true, new PublicKeyParameter<RSAPublicKey>(keyPair.publicKey));
//        RSAPrivateKey privateKey = keyPair.privateKey;
//        RSAPublicKey publicKey = keyPair.publicKey;
//        print("pubkey: ${publicKey.n} privKey: ${privateKey.d}");
//
//        var cipherText = cipher.process(new Uint8List.fromList("Hello World".codeUnits));
//
//        RSAPrivateKey priv = RSAPrivateKey(privateKey.modulus, privateKey.exponent, privateKey.p, privateKey.q);
//        print("Encrypted: ${new String.fromCharCodes(cipherText)}");
//        cipher.init( false, new PrivateKeyParameter<RSAPrivateKey>(keyPair.privateKey));
//        var cipher2 = new RSAEngine()..init(false, new PrivateKeyParameter<RSAPrivateKey>(priv));
//        var decrypt = cipher2.process(cipherText);
//        //cipher.init( false, new PrivateKeyParameter(keyPair.privateKey) )
//        var decrypted = cipher.process(cipherText);
//        print("decrypt2: ${new String.fromCharCodes(decrypt)}");
//        print("Decrypted: ${new String.fromCharCodes(decrypted)}");
      }, child: new Icon(Icons.add),),
    );
  }
}
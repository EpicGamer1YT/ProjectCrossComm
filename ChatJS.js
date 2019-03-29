require("firebase");
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);
require("firebase/app");
require("firebase/auth");
require("firebase/database");
require("cryptico");
const cryptico = require("cryptico");
var database = firebase.database();
var userkey;
var remoteEmail;
var target;
var local;
var localuuid = firebase.auth().currentUser().uid;
var targetUID;
var returnEmail;
function searchEmails(email) {
    var username;
    database.ref("/users/emailConv/" + email).once().then( (snapshot) => {
        //On completion
        target = snapshot.val();
        username = (snapshot.val() && snapshot.val().name);
        remoteEmail  = (snapshot.val() && snapshot.val().email);
        console.log(snapshot.val());
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
    if (remoteEmail.equals(email)) {
        return remoteEmail;
    } else {
        return "No emails found";
    }
}
function parseSearchedEmails() {
    var email = document.getElementById("findEmail").value;
    var modifiedEmail = email.replace(/\./g, ",");
    returnEmail = searchEmails(modifiedEmail);
    if (returnEmail.equals("No emails found")) {
        document.getElementById("listHere").value = "No users of that name found."; //replaces value of node

    } else {
        // noinspection JSJQueryEfficiency
        $("#listHere").append("Users found:"); //Adds to value of node
        // noinspection JSJQueryEfficiency
        $("#listHere").append(returnEmail); //Adds to value of node
        // noinspection JSJQueryEfficiency
        $("#listHere").attr("href", "javascript:void(0)"); //Should change the text to be clickablt to start chat
        // noinspection JSJQueryEfficiency
        $("#listHere").attr("onclick", "parseSearchedEmails()"); //Should set the onclick to run all necessary chat functions

        generateKeyPair(); //Passes function off to get keypair generated.
    }

}

function startChat(user, userkey, userPubKey) { //Will start an encrypted chat between two users FIXME: Needs rewriting
    target = database.ref("/users/emailConv/" + returnEmail).once();
    targetUID = target.uid;
    var localUID = firebase.auth().currentUser().uid;

    database.ref("/chats/" + localUID + " " + targetUID + "/" + localUID + "/pubkey").set({
        "pubkey": userPubKey.toString(),
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
}

/**
 * uses Cryptico.js to generate a public/private keypair
 * if the user already has a keypair, it passes that one off to the chat.
 */
function generateKeyPair() {
    var position = database.ref("/users/emailConv/" + local.email.replace(/\./g, "") + "/chats/" + targetUID).once();
    if (position) {
        database.ref("/chats/" + localuuid + " " + targetUID + "/" + localuuid).once().then( (snapshot) => {
            if (typeof snapshot.val().privkey == null) {
                var passPhrase = "Javascript is incredibly inconsistent."; //Is this visible in our code? Yes. Does it matter? No. It's seeded.
                var bits = 1024;
                userkeynew = cryptico.generateRSAKey(passPhrase, bits);
                var userPubKeynew = cryptico.publicKeyString(userkeynew);
                database.ref("/chats/" + localUID + " " + targetUID + "/" + localUID + "/privkey").set({
                    "privkey": cryptico.privateKey(userkeynew).toString,
                    "pubkey": userPubKeynew.toString(),
                }).catch(function(error) {
                    console.log(error.message);
                    console.log(error.code);
                });
                startChat(firebase.auth().currentUser(), userkeynew, userPubKeynew);
            } else {
                var userkey = snapshot.val().privkey;
                var userPubKey = snapshot.val().pubKey;
                startChat(firebase.auth().currentUser(), userkey, userPubKey);
            }
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/" + targetUID + " " +localuuid + "/" + localuuid).once().then( (snapshot) => {
            if (typeof snapshot.val().privkey == null) {
                var passPhrase = "Javascript is incredibly inconsistent."; //Is this visible in our code? Yes. Does it matter? No. It's seeded.
                var bits = 1024;
                userkeynew = cryptico.generateRSAKey(passPhrase, bits);
                var userPubKeynew = cryptico.publicKeyString(userkeynew);
                startChat(firebase.auth().currentUser(), userkeynew, userPubKeynew);
            } else {
                var userkey = snapshot.val().privkey;
                var userPubKey = snapshot.val().pubKey;
                startChat(firebase.auth().currentUser(), userkey, userPubKey);
            }
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    }


}
//SPLITTER AND ENCRYPTION KEY REMOVED
function sendMessage(user, userPubKey, userkey) { //TEMPORARY. NOT TO BE IMPLEMENTED WITHOUT TEJAS'S APPROVAL
    var date = new Date();
    var timestamp = date.getTime();
    var localEmail = firebase.auth().currentUser().email;
    var position = database.ref("/users/emailConv/" + localEmail + "/chats/" + targetUID).once();
    if (position) {
        database.ref("/chats/" + localuuid + " " + targetUID + "/" + localuuid + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            "message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/" + targetUID + " " + localuuid + "/" + localuuid + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            "message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    }
}
window.onload = function () {
    var date = new Date();
    var timestamp = date.getTime();
    var localuuid = firebase.auth().currentUser().uid;
    var localEmail = firebase.auth().currentUser().email;
    var position = database.ref("/users/emailConv/" + localEmail + "/chats").once(targetUID);
    if (position) {
        database.ref("/chats/" + localuuid + " " + targetUID + "/" + localuuid + "/messages/").on("child_updated", (data, prevChildKey) => {
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            Object.keys(newpost).map((key, index) => {
                console.log(newpost[key]['message']); //{Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)
                var decrypt = cryptico.decrypt(newpost[key]['message'], userkey).plaintext;

                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['sender'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + decrypt + "</span>");

            }).catch( (error) => {
                console.log(error.message);
                console.log(error.code);
            });
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/" + targetUID + " " + localuuid + "/" + localuuid + "/messages/").on("child_updated", (data, prevChildKey) => {
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            Object.keys(newpost).map((key, index) => {
                console.log(newpost[key]['message']); //{Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)
                var decrypt = cryptico.decrypt(newpost[key]['message'], userkey).plaintext;

                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['sender'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + decrypt + "</span>");

            }).catch( (error) => {
                console.log(error.message);
                console.log(error.code);
            });
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    }
};



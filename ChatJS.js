require("https://www.gstatic.com/firebasejs/5.8.5/firebase.js");
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);
require("https://www.gstatic.com/firebasejs/5.8.5/firebase-app.js");
require("https://www.gstatic.com/firebasejs/5.8.5/firebase-auth.js");
require("https://www.gstatic.com/firebasejs/5.8.5/firebase-database.js");
var database = firebase.database();
var remoteEmail;
var target;
var local;
var targetUID;
var userkey;

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
    var modifiedEmail = email.replace(".", ",");
    var returnEmail = searchEmails(modifiedEmail);
    if (returnEmail.equals("No emails found")) {
        document.getElementById("return").value = "No emails found";

    } else {
        document.getElementById("return").value = returnEmail;
    }

}

function startChat(user, userkey, userPubKey) { //Will start an encrypted chat between two users
    target = database.ref("/users/emailConv/" + remoteEmail).once()
    targetUID = target.uid;
    var localUID = firebase.auth().currentUser().uid;
    database.ref("/chats/" + localUID + " " + targetUID + "/" + localUID + "/privkey").set({
        "privkey": cryptico.privateKey(userkey).toString,
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
    database.ref("/chats/" + localUID + " " + targetUID + "/" + localUID + "/pubkey").set({
        "pubkey": userPubKey.toString(),
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
}

function generateKeyPair() {
    var passPhrase = "Your Mother Was A Hamster";
    var bits = 1024;
    userkey = cryptico.generateRSAKey(passPhrase, bits);
    var userPubKey = cryptico.publicKeyString(userkey);
    startChat(firebase.auth().currentUser(), userkey, userPubKey);
}
function showPassPhraseInput() {
    let x = document.getElementById("hiddenPass");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
function splitter() {
    parseSearchedEmails();
    showPassPhraseInput();
}
function sendMessage(user, userPubKey, userkey) { //TEMPORARY. NOT TO BE IMPLEMENTED WITHOUT TEJAS'S APPROVAL
    var date = new Date();
    var timestamp = date.getTime();
    var localuuid = firebase.auth().currentUser().uid;
    var localEmail = firebase.auth().currentUser().email;
    var position = database.ref("/users/emailConv/" + localEmail + "/chats").once(targetUID);
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
function fetcher() {
    var date = new Date();
    var timestamp = date.getTime();
    var localuuid = firebase.auth().currentUser().uid;
    var localEmail = firebase.auth().currentUser().email;
    var position = database.ref("/users/emailConv/" + localEmail + "/chats").once(targetUID);
    if (position) {
        database.ref("/chats/" + localuuid + " " + targetUID + "/" + localuuid + "/messages/").on("child_updated", (data, prevChildKey) => {
            let chatField = document.getElementById("textfield");
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            var targetName;
            Object.keys(newpost).map(function(key, index) {
                console.log(cryptico.decrypt(newpost[key]['message'], userkey).plaintext); //Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)

                database.ref("/chats/" + localuuid + " " + targetUID + "/" + newpost[key]['sender'] + "/name").once('name').then( (snapshot) => {
                    targetName = (snapshot.val() && snapshot.val().name) || "Anonymous";
                }).catch( (error) => {
                    console.log(error.message);
                    console.log(error.code);
                });
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + targetName + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + cryptico.decrypt(newpost[key]['message'], userkey).plaintext + "</span>");

            });
        });
    } else {
        database.ref("/chats/" + targetUID + " " + localuuid + "/" + localuuid + "/messages/").on("child_updated", (data, prevChildKey) => {
            let chatField = document.getElementById("textfield");
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            var targetName;
            Object.keys(newpost).map(function(key, index) {
                console.log(cryptico.decrypt(newpost[key]['message'], userkey).plaintext); //Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)

                database.ref("/chats/" + localuuid + " " + targetUID + "/" + newpost[key]['sender'] + "/name").once('name').then( (snapshot) => {
                    targetName = (snapshot.val() && snapshot.val().name) || "Anonymous";
                }).catch( (error) => {
                    console.log(error.message);
                    console.log(error.code);
                });
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + targetName + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + cryptico.decrypt(newpost[key]['message'], userkey).plaintext + "</span>");

            });
        });
    }
}





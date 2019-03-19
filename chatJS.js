var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);
var database = firebase.database();
var remoteEmail;
var target;
var local;
var targetUID;

function searchEmails(email) {
    var username;
    database.ref("/users/emailConv/" + email).once().then(function(snapshot) {
        //On completion
       username = (snapshot.val() && snapshot.val().username);
       remoteEmail  = (snapshot.val() && snapshot.val().email);
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
    var passPhrase = document.getElementById("passInput").value;
    var bits = 1024;
    var userkey = cryptico.generateRSAKey(passPhrase, bits);
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
    var localuuid = firebase.auth().currentUser().uid;
    var localEmail = firebase.auth().currentUser().email;
    var position = database.ref("/users/emailConv/" + localEmail + "/chats").once(targetUID);
    if (position) {
        database.ref("/chats/" + localuuid + targetUID + "/messages").set({
            "timestamp":  document.getElementById("sendmessage").value,
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/" + targetUID + localuuid + "/messages").set({
            "timestamp":  document.getElementById("sendmessage").value,
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    }
}
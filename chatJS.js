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

var target;
var local;

function searchEmails(email) {
    var remoteEmail;
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
    target = document.getElementById("findEmail").value;
    var email = document.getElementById("findEmail").value;
    var modifiedEmail = email.replace(".", ",");
    var returnEmail = searchEmails(modifiedEmail);
    if (returnEmail.equals("No emails found")) {
        document.getElementById("return").value = "No emails found";

    } else {
        document.getElementById("return").value = returnEmail;
    }
}

function startChat() { //Will start an encrypted chat between two users

}

function generateKeyPair() {
    
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
    generateKeyPair();
}
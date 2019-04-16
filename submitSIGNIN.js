const firebase = require("firebase"); //Required to link with Firebase
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config); //no touchie
require("firebase/app");
require("firebase/auth");
require("firebase/database");
function signIN() {
    var email = document.getElementById("signinEMAIL").value;
    var pass = document.getElementById("signinPASS").value;
    console.log("hello");
    firebase.auth().signInWithEmailAndPassword(email, pass).then(function() {
        console.log("Successfully signed in");
    }).catch((error) => {
        console.log(error.message);
        console.log(error.code);
    });
}
function googleSignIn() {
    var provider = new firebase.auth.GoogleAuthProvider();
    firebase.auth().languageCode = 'en';
    firebase.auth().signInWithPopup(provider).then(function(result) {
        var user = result.user; //Contains all user info that Google provided us
        writeToDatabaseFromGoogleSignIn(user.email, user.displayName, user.uid).then( () => {
            console.log("All database writing complete.");
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
        window.location.pathname = 'ChatLayout.html'
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
}


function writeToDatabaseFromGoogleSignIn(email, username, uuid) {
    database.ref("/users/" + uuid).set({
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("First database write complete.");
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
    database.ref("/users/emailConv/" + email.replace(/\./g, ",")).set({ //use regex to replace all periods to validate branch name
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("All database writing complete.");
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
    window.location.pathname = 'chatlayout.html'
}
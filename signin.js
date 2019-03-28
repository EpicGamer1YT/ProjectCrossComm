require("firebase"); //Required to link with Firebase
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
    var email = document.getElementById("signinEMAIL");
    var pass = document.getElementById("signinPASS");
    firebase.auth().signInWithEmailAndPassword(email, pass).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
}
function googleSignIn() {
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope("https://www.googleapis.com/auth/contacts.readonly");
    firebase.auth().languageCode = 'en';
    firebase.auth().signInWithPopup(provider).then( (result) => {
        var token = result.credential.accessToken; //Google Auth access token
        var user = result.user; //Contains all user info that Google provided us
        writeToDatabaseFromGoogleSignIn(user.email, user.displayName, user.uid).then( () => {
            console.log("All database writing complete.");
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
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
}


document.getElementById("signinGOOGLEBUTTON").addEventListener("click", googleSignIn); //onclick listener for google
document.getElementById("signinSUBMIT").addEventListener("click", signIN); //onclick listener for native
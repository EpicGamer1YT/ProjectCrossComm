require("firebase");
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
require("firebase/app");
require("firebase/auth");
require("firebase/database");
firebase.initializeApp(config);
var database = firebase.database();


function signUpWithEmail() {
    const username = document.getElementById("signupNAME").value;
    const email = document.getElementById("signupEMAIL").value;
    const pass = document.getElementById("signupPASS").value;
    firebase.auth().createUserWithEmailAndPassword(email, pass).then((result) => {
        var user = firebase.auth().currentUser;
        var uidvalue = user.uid;
        console.log(uidvalue);
        user.updateProfile({
            displayName: username,
        }).then(function() {
            var displayName = user.displayName;
        }, function(error) {
            console.log(error.message);
        });

        writeUserDataFromEmailSignIn(email, username, uidvalue);
    }).catch((error) => {
        alert(error.message);
        console.log(error.message);
        console.log(error.code);
    });

}
document.getElementById("signupSUBMIT").addEventListener("click", function() {
    signUpWithEmail();
});

function writeUserDataFromEmailSignIn(email, username, uuid) {
    database.ref('/users/' + uuid).set({
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("Database push complete.");
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });

    database.ref("/users/emailConv/" + email.replace(/\./g, ",")).set({ //use regex to replace all periods to validate branch name
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("emailConv push complete.");
        window.location.pathname = 'ChatLayout.html';
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
}


function googleSignIn() {
    var provider = new firebase.auth().GoogleAuthProvider();
    provider.addScope("https://www.googleapis.com/auth/contacts.readonly");
    firebase.auth().languageCode = 'en';
    firebase.auth().signInWithPopup(provider).then( (result) => {
        var token = result.credential.accessToken; //Google Auth access token
        var user = result.user; //COntains all user infor that Google provided us
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
        "imageUrl": photoUrl,
    }).then( () => {
        console.log("First database write complete.");
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
    database.ref("/users/emailConv/" + email.replace(/\./g, ",")).set({
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
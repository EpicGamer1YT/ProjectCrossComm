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
function showAccCreate() {
    var x = document.getElementById("hiddenaccountcreation");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
function submitAcc() {
    var email = document.getElementById("emailinput").value;
    var password = document.getElementById("passinput").value;
    var username = document.getElementById("usernameinput");


    // noinspection JSUnresolvedFunction
    firebase.auth().createUserWithEmailAndPassword(email, password).then(function(result, email, username) {
        writeUserDataFromEmailSignin(email, username, result.user.uid);
    }).catch(function(error) {
        //Handle errors here
    });

}
function writeUserDataFromEmailSignin(email, name, uuid) {
    database.ref('users/' + uuid).set({
        name: name,
        email: email,
        uid: uuid,
    });
}
function showsignin() {
    var x = document.getElementById("hiddensignin");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
function googlesignin() {
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope("https://www.googleapis.com/auth/contacts.readonly");
    firebase.auth().languageCode = 'en';
    firebase.auth().signInWithPopup(provider).then(function(result) {
        var token = result.credential.accessToken; //Google Auth access token
        var user = result.user; //Contains all user info that Google provided us
    }).catch(function(error) {
        //handle errors
    });

    
}
function signInUser() {
    var email = document.getElementById("emailreauth");
    var pass = document.getElementById("passreauth");
    firebase.auth().signInWithEmailAndPassword(email, pass).catch(function(error) {
        //Handle errors here
        let errorCode = error.code;
        let errorMessage = error.MESSAGE;
    });
}
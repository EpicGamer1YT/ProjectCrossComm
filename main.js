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
var database = firebase.database();
function showAccCreate() { //Hides and shows account create button
    var x = document.getElementById("hiddenaccountcreation");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}

var database = firebase.database();


function showAccCreate() { //Hides and shows account create button
    var x = document.getElementById("hiddenaccountcreation");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}
function submitAcc() { //On submit button pressed
    alert("Signing in");
    var email = document.getElementById("emailinput").value;
    var password = document.getElementById("passinput").value;
    var username = document.getElementById("usernameinput").value;
    console.log(email + password +username);
    alert("recorded values");


    firebase.auth().createUserWithEmailAndPassword(email,password).then(function(result) {
        alert("Gets into .then");
        var user = firebase.auth().currentUser;
        var uidvalue = user.uid;
        console.log(uidvalue);
        console.log(uidvalue);
        alert("User value recorded");
        writeUserDataFromEmailSignin(email, username,uidvalue);
        alert(user.uid);
    }).catch(function(error) {
        alert(error.message);
        console.log(error.message);
        console.log(error.code);
    });
}


function writeUserDataFromEmailSignin(email, name, uuid) { //Writes user data to database if user signs in
    alert("Entered function");
    database.ref('users/' + uuid).set({
        "name": name,
        "email": email,
        "uid": uuid,
    }).then(function() {
        console.log("Push complete.")
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
    database.ref('users/emailConv/' + email.replace(".", ",")).set({
        "name": name,
        "email": email,
        "uid": uuid,
    }).then(function() {
        console.log("Push complete.")
    }).catch(function (error) {
        console.log(error.message);
        console.log(error.code);
    });
}





function logout()
{
    firebase.auth().signOut().then(function() {
        // Sign-out successful.
    }).catch(function(error) {
        // An error happened.
    });
}

function status()
{
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            var emailv =user.email;
            console.log("User is signed in. em ankunav enti "+ emailv);
        } else {
            console.log("No user is signed in.");
        }
    });
}

//Testing if auth state changes
firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
        alert("User is signed in.");
        document.getElementById("debugtest").innerHTML = "Signed in";
    }
    else
    {
        document.getElementById("debugtest").innerHTML = "NOT LOGGED IN ";
    }
});



function showsignin() {
    var x = document.getElementById("hiddensignin");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
}


function signInUser() { //Uses email sign-in so signin to existing account
    var email = document.getElementById("emailreauth").value;
    var pass = document.getElementById("passreauth").value;
    // noinspection JSUnresolvedFunction
    firebase.auth().signInWithEmailAndPassword(email, pass).catch(function (error) {
        //Handle errors here
        let errorCode = error.code;
        let errorMessage = error.MESSAGE;
        console.log(errorCode);
        console.log(errorMessage);
    });
}



/*function submitAcc() { //On submit button pressed
    console.log("Signing in");
    var email = document.getElementById("emailinput").value;
    var password = document.getElementById("passinput").value;
    var username = document.getElementById("usernameinput").value;
    //console.log(email + password +username);
    var user;
    console.log("Recorded Values");
    firebase.auth().createUserWithEmailAndPassword(email,password).then(function(result) {
        console.log("Gets into .then");
        var user = firebase.auth().currentUser;
        var uidvalue = user.uid;
        console.log(uidvalue);
        console.log(uidvalue);
        console.log("User value recorded");
        writeUserDataFromEmailSignin(email, username,uidvalue);
        console.log(user.uid);
    }).catch(function(error) {
        alert(error.message);
        console.log(error.message);
        console.log(error.code);
    });
    console.log("End of Function");
}*/




//Testing if auth state changes
firebase.auth().onAuthStateChanged(function (user) {
    if (user) {
        alert("User is signed in.");
        alert(user.uid);
        document.getElementById("debugtest").innerHTML = "Signed in";
    }
});
/*function writeUserDataFromEmailSignin(email, name, uuid) { //Writes user data to database if user signs in
    alert("Entered function");
    database.ref('users/' + uuid).set({
        "name": name,
        "email": email,
        "uid": uuid,
    }).then(function() {
        alert("Completed");
    }).catch(function() {
        console.log(error.message);
        console.log(error.code);
    })
}*/

function googlesignin() { //Signs people into app via Google
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope("https://www.googleapis.com/auth/contacts.readonly");
    firebase.auth().languageCode = 'en';
    firebase.auth().signInWithPopup(provider).then(function(result) {
        var token = result.credential.accessToken; //Google Auth access token
        var user = result.user; //Contains all user info that Google provided us
        writeToDatabaseFromGoogle(user.email, user.displayName, user.uid, user.photoUrl);
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });

    
}
function writeToDatabaseFromGoogle(email, name, uuid, image_url) { //Writes user data to database from Google signin
    database.ref("users/" + uuid).set({
        "name": name,
        "email": email,
        //"imageUrl": image_url,
        "uid": uuid,
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });
}
/*
function signInUser() { //Uses email sign-in so signin to existing account
    var email = document.getElementById("emailreauth");
    var pass = document.getElementById("passreauth");
    // noinspection JSUnresolvedFunction
    firebase.auth().signInWithEmailAndPassword(email, pass).catch(function (error) {
        //Handle errors here
        let errorCode = error.code;
        let errorMessage = error.MESSAGE;
        console.log(errorCode);
        console.log(errorMessage);
    });
}*/

function google() { //DEPRECATED
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope('https://www.googleapis.com/auth/contacts.readonly');

    firebase.auth().languageCode = 'en';

    firebase.auth().signInWithPopup(provider).then ( (result) => {
        var token = result.credential.accessToken;
        var user = result.user;
    }).catch( (error) => {
        console.log(error.code);
        console.log(error.message);
    });
}
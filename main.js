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
function submitAcc() { //Deprecated as of 2019.03.12
    alert("Signing in");
    var email = document.getElementById("emailinput").value;
    var password = document.getElementById("passinput").value;
    var username = document.getElementById("usernameinput").value;
    var user;
    alert("recorded values");
    firebase.auth().createUserWithEmailAndPassword(email, password).then(function(result) {
        alert("Gets into .then");
        user = result.value;
        alert("User value recorded");
        writeUserDataFromEmailSignin(email, username, user.uid);
        alert(user.uid);
    }).catch(function(error) {
        alert(error.message);
        console.log(error.message);
        console.log(error.code);
    });

}
function writeUserDataFromEmailSignin(email, name, uuid) { //Deprecated as of 2019.03.12
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
        writeToDatabaseFromGoogle(user.email, user.displayName, user.uid, user.photoUrl);
    }).catch(function(error) {
        console.log(error.message);
        console.log(error.code);
    });

    
}
function writeToDatabaseFromGoogle(email, name, uuid, image_url) {
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
function signInUser() {
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
}
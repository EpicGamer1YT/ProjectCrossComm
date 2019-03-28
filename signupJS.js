window.open(
    'https://app.termly.io/document/privacy-policy/0ae020d8-ee05-4202-a0c7-d4ff19e8f661',
    '_blank' // <- This is what makes it open in a new window.
);
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


function signUpWithEmail() {
    const username = document.getElementById("signupNAME").value;
    const email = document.getElementById("signupEMAIL").value;
    const pass = document.getElementById("signupPASS").value;
    console.log(email + " " + pass + " " + username);
    firebase.auth().createUserWithEmailAndPassword(email, password).then((result) => {
        var user = firebase.auth().currentUser;
        var uidvalue = user.uid;
        console.log(uidvalue)
        writeUserDataFromEmailSignIn(email, username, uidvalue).then( () => {
            console.log("All pushes completed.")
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    }).catch((error) => {
        alert(error.message);
        console.log(error.message);
        console.log(error.code);
    });

}

function writeUserDataFromEmailSignIn(email, username, uuid) {
    database.ref('/users/' + uuid).set({
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("Database push complete.")
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });

    database.ref('/users/emailConv' + email.replace(".", ",")).set({
        "name": username,
        "email": email,
        "uid": uuid,
    }).then( () => {
        console.log("emailConv push complete.");
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
        writeToDatabaseFromGoogleSignIn(user.email, user.displayName, user.uid, user.photoUrl).then( () => {
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

function writeToDatabaseFromGoogleSignIn(email, username, uuid, photoUrl) {
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
    database.ref("/users/emailConv" + email.replace(".", ",")).set({
        "name": username,
        "email": email,
        "uid": uuid,
        "imageUrl": photoUrl,
    }).then( () => {
        console.log("All database writing complete.");
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
}
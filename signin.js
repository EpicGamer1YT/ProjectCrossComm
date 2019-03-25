var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);

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
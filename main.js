//Don't break this please
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);
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
    firebase.auth().createUserWithEmailAndPassword(email, password).catch(function (error) {
       console.log(error.log);
       console.log(error.message);
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
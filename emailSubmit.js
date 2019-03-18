var config = { //Firebase init
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com",
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);

//___________________________________________________________________________


//On submit button pressed
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


function writeUserDataFromEmailSignin(email, name, uuid) { //Writes user data to database if user signs in
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
var firebase = require("firebase"); //Node functions with Browserify to bundle required modules
var config = {
    apiKey: "AIzaSyAhglAXFWaJhtvOrfeugAMgJHrBw5CUNEc",
    authDomain: "projectcrosscomm.firebaseapp.com",
    databaseURL: "https://projectcrosscomm.firebaseio.com", //No touchie
    projectId: "projectcrosscomm",
    storageBucket: "projectcrosscomm.appspot.com",
    messagingSenderId: "412861101382"
};
firebase.initializeApp(config);
require("firebase/app");
require("firebase/auth");
require("firebase/database");
require("cryptico");
const cryptico = require("cryptico"); //Node with browserify for RSA
var database = firebase.database();
var userkey;
var remoteEmail;
var target;
var local;
var localuuid;
var targetUID;
var returnEmail;
var crypt = new JSEncrypt();
// var rsa = new RSA();
firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        localuuid = user.uid;
    } else {
        alert("Please sign in!");
        window.location.pathname = 'signin.html'

// No user is signed in.
    }
});

document.getElementById("findEmailSubmit").addEventListener("click", parseSearchedEmails)
function searchEmails(email) { //Function searches database for requested email
    var username;
    var nully = true;
    database.ref("/users/emailConv/" + email).once('value', (snapshot) => {
        target = snapshot.val();
        username = (snapshot.val() && snapshot.val().name);
        remoteEmail = (snapshot.val() && snapshot.val().email);
        console.log(snapshot.val());
        console.log("Here");
        console.log(snapshot.val());
        if (snapshot.val() === null) {
            console.log("null");
            nully = true;
            return "No emails found";
        } else {
            nully = false;
            return email;

        }
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });
    if (nully) {
        console.log("null");
    } else {
        //return email;
    }
}

function parseSearchedEmails() { //Function calls searchEmails and parses value; allows user to start chat
    var email = document.getElementById("findEmail").value;
    var modifiedEmail = email.replace(/\./g, ",");
    //returnEmail = searchEmails(modifiedEmail);
    database.ref("/users/emailConv/" + modifiedEmail).once('value', (snapshot) => {
        target = snapshot.val();
        username = (snapshot.val() && snapshot.val().name);
        remoteEmail = (snapshot.val() && snapshot.val().email);
        console.log(snapshot.val());
        console.log("Here");
        console.log(snapshot.val());
        if (snapshot.val() === null) {
            console.log("here");
            document.getElementById("listHere").value = "No users of that name found.";
        } else {
            console.log(email);
            // noinspection JSJQueryEfficiency
            $("#chatName").text("Chatting with " + snapshot.val()["name"]);
            $("#listHere").append("Users found:"); //Adds to value of node
            // noinspection JSJQueryEfficiency
            $("#listHere").append(email); //Adds to value of node
            // noinspection JSJQueryEfficiency
            $("#listHere").attr("href", "javascript:void(0)"); //Should change the text to be clickable to start chat
            // noinspection JSJQueryEfficiency
            $("#listHere").attr("onclick", "generateKeyPair()"); //Should set the onclick to run all necessary chat functions

            generateKeyPair(email, snapshot.val()['name']); //Pass
        }
    }).catch( (error) => {
        console.log(error.message);
        console.log(error.code);
    });

}

async function startChat(user, userkey, userPubKey, oUID, position, name) { //Will start an encrypted chat between two users FIXME: Needs rewriting
    targetUID = oUID;
    var localUID = user.uid;
    console.log(position);
    var order = position === "true" ? localUID + " " + targetUID : targetUID + " " + localUID;
    console.log(order);
    var accepted;
    var localNme;
    if (typeof position != null) {
        await database.ref("/chats/compTemp/" + order + "/accepted/" + targetUID + "/").once('value', function (snapshot) {
            if (snapshot.val() != null) {
                accepted = snapshot.val();
            }
        });
        if (accepted === "true") {
            $("#chatField").text("")
            database.ref("/chats/compTemp/" + order + "/" + localuuid + "/messages/").on("child_added", async (data, prevChildKey) => {
                var newpost = data.val();
                console.log(newpost);
                Object.keys(newpost).sort();
                console.log(newpost);
                const ordered = Object.keys(newpost).sort();
                // Object.keys(newpost).map((key, index) => {
                //
                //
                // }).catch( (error) => {
                //     console.log(error.message);
                //     console.log(error.code);
                // });
                console.log(newpost['message']); //{Prints encrypted message(all messages looped)
                console.log(newpost['date']);//Prints date stamp(all messages looped)
                console.log(newpost['time']);//Prints time stamp(all messages looped)
                console.log(newpost['sender']);//Prints sender uid(all messages looped)
                var nme; //name to use for msg
                if (newpost['sender'] === localUID) {
                    nme = user.displayName
                } else {
                    nme = name
                }
                nme = nme + " at "
                var time = newpost['time'] + ": "
                var msg = newpost['message'] + "\n";
                // crypt.setPublicKey(userPubKey);
                // console.log(userPubKey);
                // var encrypted = await crypt.encrypt("HI");
                // console.log(encrypted);
                // console.log(userkey);
                // crypt.setPrivateKey(userkey);
                // var decrypt = await crypt.decrypt(encrypted);
                // console.log(decrypt);
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<p>" + nme + time + msg + "</p>");
                // // noinspection JSJQueryEfficiency
                // $("#chatField").append("<p>" + time + "</p>");
                // // noinspection JSJQueryEfficiency
                // $("#chatField").append("<p>" + msg + "</p>");
                //noinspection JSJQueryEfficiency
                $("#chatField").append("<br>");
            })
        } else {
            var myRef = firebase.database().ref("/chats/compTemp/" + order + "/accepted/" + oUID).set("true");
        }
    }
    // database.ref("/chats/compTemp/" + order + "/" + localUID + "/").set({
    //     "pubkey": userPubKey.toString(), //Pushes public key string to database.
    //     "privkey": userkey.toString(),
    // }).catch(function(error) {
    //     console.log(error.message);
    //     console.log(error.code);
    // });
}

/**
 * uses Cryptico.js to generate a public/private keypair
 * if the user already has a keypair, it passes that one off to the chat.
 */
async function generateKeyPair(email, name) {
    var localemail = firebase.auth().currentUser.email;
    var oUID;
    var localuuid = firebase.auth().currentUser.uid;
    await database.ref("/users/emailConv/" + email.replace(/\./g, ",") + "/uid/").once('value', function(snap) {
        if (snap.val() != null) {
            oUID = snap.val();
        }
    });
    var position;
    await database.ref("/users/emailConv/" + localemail.replace(/\./g, ",") + "/compTemp/" + oUID).once('value', function(snap) {
        if (snap.val() != null) {
            position = snap.val();
            console.log(position);
        }
    }); //FIXME: error: cannot read property of undefined: local.email.replace
    var order = position === "true" ? localuuid + " " + oUID : oUID + " " + localuuid;
    console.log(order);
    if (position ==="true" || position === "false") {
        var myRef = firebase.database().ref("/chats/compTemp/" + order + "/accepted/" + localuuid).set("true");

        var pubKey;
        var privKey;
        await database.ref("/chats/compTemp/" + order + "/" + localuuid + "/privKey").once('value',  (snapshot) => {
            console.log(snapshot.val());
            if (snapshot.val() != null) {
                privKey = snapshot.val();
            }
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
        await database.ref("/chats/compTemp/" + order + "/" + localuuid + "/pubKey").once('value',  (snapshot) => {
            console.log(snapshot.val());
            if (snapshot.val() != null) {
                pubKey = snapshot.val();
            }
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
        if (privKey == null || pubKey == null) {
            var passPhrase = "Javascript is incredibly inconsistent."; //Is this visible in our code? Yes. Does it matter? No. It's seeded.
            var bits = 2048;
            userkeynew = cryptico.generateRSAKey(passPhrase, bits);
            var userPubKeynew = cryptico.publicKeyString(userkeynew);
            // database.ref("/chats/compTemp/" + order + "/" + localuuid + "/").set({
            //     "privkey": cryptico.privateKey(userkeynew).toString(),
            //     "pubkey": userPubKeynew.toString(),
            // }).catch(function(error) {
            //     console.log(error.message);
            //     console.log(error.code);
            // });
            startChat(firebase.auth().currentUser, userkeynew, userPubKeynew, oUID, position, name);
        } else {
            startChat(firebase.auth().currentUser, privKey, pubKey, oUID, position, name);
        }

    } else {
        var passPhrase = "Javascript is incredibly inconsistent."; //Is this visible in our code? Yes. Does it matter? No. It's seeded.
        var bits = 2048;
        userkeynew = cryptico.generateRSAKey(passPhrase, bits);
        var userPubKeynew = cryptico.publicKeyString(userkeynew);
        // database.ref("/chats/compTemp/" + localuuid + " " + oUID + "/" + localuuid + "/").set({
        //     "privkey": cryptico.privateKey(userkeynew).toString(),
        //     "pubkey": userPubKeynew.toString(),
        // }).catch(function(error) {
        //     console.log(error.message);
        //     console.log(error.code);
        // });
        var myRef = firebase.database().ref("/chats/compTemp/" + localuuid + " " + oUID + "/accepted/" + localuuid).set("true");
        var myRef = firebase.database().ref("/users/emailConv/" + localemail.replace(/\./g, ",") + "/compTemp/" + oUID).set("true");
        var myRef = firebase.database().ref("/users/emailConv/" + email.replace(/\./g, ",") + "/compTemp/" + localuuid).set("false")
        startChat(firebase.auth().currentUser, userkeynew, userPubKeynew, oUID, "true", name);
    }


}
//SPLITTER AND ENCRYPTION KEY REMOVED
document.getElementById("messageSubmit").addEventListener("click", sendMessage);
async function sendMessage() { //TEMPORARY. NOT TO BE IMPLEMENTED WITHOUT TEJAS'S APPROVAL
    var date = new Date();
    var user = firebase.auth().currentUser;
    var timestamp = date.getTime();
    var localEmail = firebase.auth().currentUser.email;
    var position;
    var oUID = targetUID;
    await database.ref("/users/emailConv/" + localEmail.replace(/\./g, ",") + "/compTemp/" + targetUID).once('value', function(snapshot) {
        if(snapshot.val() != null) {
            // Object.keys(snapshot.val()).map((key, index) => {
            //     oUID = key;
            //     position = snapshot.val()[key];
            //     console.log(oUID);
            //     console.log(position);
            // });
            // oUID = snapshot.val()
            console.log(snapshot.val());
            position = snapshot.val();
        }
    });

    if (position === "true") {
        database.ref("/chats/compTemp/" + localuuid + " " + oUID + "/" + localuuid + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            // "message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "message": document.getElementById("sendmessage").value,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
        database.ref("/chats/compTemp/" + localuuid + " " + oUID + "/" + oUID + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            // "message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "message": document.getElementById("sendmessage").value,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/compTemp/" + oUID + " " + localuuid + "/" + localuuid + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            //"message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "message": document.getElementById("sendmessage").value,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
        database.ref("/chats/compTemp/" + oUID + " " + localuuid + "/" + oUID + "/messages/" + timestamp).set({
            "date": date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate(),
            //"message": cryptico.encrypt(document.getElementById("sendmessage").value, userPubKey).cipher,
            "message": document.getElementById("sendmessage").value,
            "sender": localuuid,
            "time": date.getHours() + "." + date.getMinutes(),
        }).catch(function(error) {
            console.log(error.message);
            console.log(error.code);
        });
    }
}



window.onload = function () {

    var date = new Date();
    var timestamp = date.getTime();
    var localuuid;
    var localEmail;
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            localuuid = user.uid;
            localEmail = user.email;
            console.log(localuuid);
        } else {
            alert("Please sign in!");
            window.location.pathname = 'signin.html'
        }
    });
    var position;
    database.ref("/users/emailConv/" + localEmail + "/compTemp/" + targetUID).once('value', (snapshot) => {
        if (snapshot != null) {
            position = snapshot.val();
        }
    });
    if (position === "true") {
        database.ref("/chats/compTemp/" + localuuid + " " + targetUID + "/" + localuuid + "/messages/").on("child_added", (data, prevChildKey) => {
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            Object.keys(newpost).map((key, index) => {
                console.log(newpost[key]['message']); //{Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)
                var decrypt = cryptico.decrypt(newpost[key]['message'], userkey).plaintext;

                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['sender'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + decrypt + "</span>");

            }).catch( (error) => {
                console.log(error.message);
                console.log(error.code);
            });
        }).catch( (error) => {
            console.log(error.message);
            console.log(error.code);
        });
    } else {
        database.ref("/chats/compTemp/" + targetUID + " " + localuuid + "/" + localuuid + "/messages/").on("child_added", (data, prevChildKey) => {
            var newpost = data.val();
            console.log(newpost);
            Object.keys(newpost).sort();
            console.log(newpost);
            const ordered = Object.keys(newpost).sort();
            Object.keys(newpost).map((key, index) => {
                console.log(newpost[key]['message']); //{Prints encrypted message(all messages looped)
                console.log(newpost[key]['date']);//Prints date stamp(all messages looped)
                console.log(newpost[key]['time']);//Prints time stamp(all messages looped)
                console.log(newpost[key]['sender']);//Prints sender uid(all messages looped)
                var decrypt = cryptico.decrypt(newpost[key]['message'], userkey).plaintext;

                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['sender'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + newpost[key]['time'] + "</span>");
                // noinspection JSJQueryEfficiency
                $("#chatField").append("<span>" + decrypt + "</span>");

            }).catch( (error) => {
                console.log(error.message);
                console.log(error.code);
            });
        });
    }
};
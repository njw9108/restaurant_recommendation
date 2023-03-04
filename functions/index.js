const functions = require("firebase-functions");
const admin = require("firebase-admin");
const auth = require("firebase-auth");

var serviceAccount = require("./restaurant-recommendatio-11d04-firebase-adminsdk-o8n06-8c6dc1f3d9.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://restaurant-recommendatio-11d04-default-rtdb.asia-southeast1.firebasedatabase.app",
});

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started
//
exports.createCustomToken = functions
  .region("asia-northeast3")
  .https.onRequest(async (request, response) => {
    const user = request.body;

    const uid = `kakao:${user.uid}`;
    const updateParams = {
      email: user.email,
      photoURL: user.photoURL,
      displayName: user.displayName,
    };

    try {
      await admin.auth().updateUser(uid, updateParams);
    } catch (e) {
      updateParams["uid"] = uid;
      try {
        await admin.auth().createUser(updateParams);
      } catch (err) {
        return response.status(401).json(err);
      }
    }

    try {
      const token = await admin.auth().createCustomToken(uid);
      response.send(token);
    } catch (err) {
      return response.status(402).json(err);
    }
  });

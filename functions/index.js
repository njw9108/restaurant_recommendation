const functions = require("firebase-functions");
const admin = require("firebase-admin");
const auth = require("firebase-auth");
const firebase_tools = require("firebase-tools");
const { getStorage } = require("firebase-admin/storage");

const serviceAccount = require("./restaurant-recommendatio-11d04-firebase-adminsdk-o8n06-8c6dc1f3d9.json");

const FIREBASE_CONFIG = JSON.parse(process.env.FIREBASE_CONFIG);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: FIREBASE_CONFIG.databaseURL,
  storageBucket: "restaurant-recommendatio-11d04.appspot.com",
});
const bucketName = "restaurant-recommendatio-11d04.appspot.com";

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

exports.deleteRestaurant = functions
  .region("asia-northeast3")
  .firestore.document("restaurant/{uid}/restaurant_list/{restaurantId}")
  .onDelete((snap, context) => {
    const { uid, restaurantId } = context.params;

    console.log(`Bucket : ${bucketName}`);

    const folder = `restaurant/${uid}`;
    //Note typically the bucket name is not needed, and you can skip             //specifying the bucket name as parameter below
    const bucket = getStorage().bucket();

    async function deleteBucket() {
      console.log(`Folder ${folder} delete initiated`);
      await bucket.deleteFiles({ prefix: folder });

      console.log(`Folder ${folder}  deleted`);
    }

    console.log(`Requesting delete of folder: ${folder}`);
    deleteBucket().catch((err) => {
      console.error(`Error occurred while deleting the folder: ${folder}`, err);
    });
  });

exports.recursiveDelete = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540,
    memory: "2GB",
  })
  .https.onCall(async (data, context) => {
    // Only allow admin users to execute this function.
    // if (!(context.auth && context.auth.token && context.auth.token.admin)) {
    if (!(context.auth && context.auth.token)) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Must be an administrative user to initiate delete."
      );
    }

    const path = data.path;
    console.log(
      `User ${context.auth.uid} has requested to delete path ${path}`
    );

    // Run a recursive delete on the given document or collection path.
    // The 'token' must be set in the functions config, and can be generated
    // at the command line by running 'firebase login:ci'.

    await firebase_tools.firestore.delete(path, {
      project: process.env.GCLOUD_PROJECT,
      recursive: true,
      force: true,
      token: functions.config().fb.token,
    });

    return {
      path: path,
    };
  });

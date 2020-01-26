const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.onCreateUser = functions.firestore
  .document("/users/{userId}")
  .onCreate(async (snapshot, context) => {
    const userCreated = snapshot.data();

    //TODO: Send email to user
  });

//On possibly delete
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snapshot, context) => {
    const postCreated = snapshot.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });

//Possibly Delete
exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;
    const postUpdated = change.after.data();

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          doc.ref.update(postUpdated);
        });
    });
  });

//TODO: Possibly delete
exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("followers");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;
      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          doc.ref.delete();
        });
    });
  });

exports.onCreateActivityFeedItem = functions.firestore
  .document("/feed/{userId}/feedItems/{activityFeedItem}")
  .onCreate(async (snapshot, context) => {
    console.log("Activity Feed item created", snapshot.data());

    const userId = context.params.userId;

    const userRef = admin.firestore().doc(`users/${userId}`);

    const doc = await userRef.get();

    const token = doc.data().token;
    const createdActivityFeedItem = snapshot.data();
    if (token) {
      sendNotification(token, createdActivityFeedItem);
    } else {
      console.log("No token for user, cannot send notification");
    }

    function sendNotification(token, activityFeedItem) {
      let body;

      switch (activityFeedItem.type) {
        //Like
        case 0:
          body = `${activityFeedItem.user} liked your post`;
          break;
        //Comment
        case 1:
          body = `${activityFeedItem.user} commented: "${activityFeedItem.text}" on your post`;
          break;
        //Attending your event
        case 2:
          body = `${activityFeedItem.user} is attending your event "${activityFeedItem.text}"`;
          break;
        default:
          break;
      }

      const message = {
        notification: { body: body },
        token: token,
        data: { recipient: userId }
      };

      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log("Succesfully sent message", response);
        })
        .catch(error => {
          console.log("Error sending messages", error);
        });
    }
  });

exports.onCreateChatMessage = functions.firestore
  .document("/chats/{chatId}/msgs/{msgId}")
  .onCreate(async (snapshot, context) => {
    const messageCreated = snapshot.data();
    const chatId = context.params.chatId;
    const senderId = messageCreated.user;

    const chat = await admin
      .firestore()
      .collection("chats")
      .doc(chatId)
      .get();
    console.log(
      "chat: " +
        chat.data().toString() +
        " name: " +
        chat.data().users.senderId.name +
        " chatId: " +
        chatId +
        " senderId: " +
        senderId
    );
    const sender = chat.data().users.senderId;

    for (let [key, value] of Object.entries(chat.data().users)) {
      if (key != senderId && value.token != null) {
        sendNotification(
          key,
          value.token,
          messageCreated.text,
          messageCreated.type,
          sender.name
        );
      }
    }

    function sendNotification(recipientId, token, text, type, senderName) {
      let body;

      console.log(
        "recipient: " +
          recipientId +
          " token: " +
          token +
          " text: " +
          text +
          " sender: " +
          sender
      );

      if (type == 0) {
        body = text;
      } else if (type == 1) {
        body = "Sent an Image";
      } else if (type == 2) {
        body = "Sent a Sticker";
      }

      const message = {
        notification: { title: senderName, body: body },
        token: token,
        data: { recipient: recipientId }
      };

      admin
        .messaging()
        .send(message)
        .then(response => {
          console.log("Succesfully sent message", response);
        })
        .catch(error => {
          console.log("Error sending messages", error);
        });
    }
  });

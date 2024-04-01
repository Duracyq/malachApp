const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.getUserIdByEmail = functions.https.onCall((data, context) => {
  const email = data.email;
  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'Email is required');
  }

  return admin.auth().getUserByEmail(email)
    .then(userRecord => {
      return { userId: userRecord.uid };
    })
    .catch(error => {
      throw new functions.https.HttpsError('not-found', 'User not found');
    });
});

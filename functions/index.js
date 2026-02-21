const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.dailyCarbonCheck = functions.pubsub
    .schedule("0 21 * * *") // 9 PM
    .timeZone("Asia/Kolkata")
    .onRun(async () => {
      const users = await admin.firestore().collection("users").get();
      const today = new Date().toDateString();

      for (const user of users.docs) {
        const token = user.data().fcmToken;
        if (!token) continue;

        const carbonDoc = await admin.firestore()
            .collection("carbonFootprints")
            .doc(user.id)
            .get();

        // ❌ No data
        if (!carbonDoc.exists) {
          await sendReminder(token);
          continue;
        }

        const data = carbonDoc.data();
        const lastUpdated = data.lastUpdated ?
        data.lastUpdated.toDate().toDateString() :
        null;


        if (lastUpdated !== today) {
        // ❌ Not filled today
          await sendReminder(token);
        } else {
        // ✅ Send summary
          const totalCO2 = carbonDoc.data().totalCO2;
          await sendSummary(token, totalCO2);
        }
      }

      return null;
    });

async function sendReminder(token) {
  await admin.messaging().send({
    token,
    notification: {
      title: "🌱 EcoTrack Reminder",
      body: "You haven't logged today's carbon usage. Please update it!",
    },
  });
}

async function sendSummary(token, totalCO2) {
  await admin.messaging().send({
    token,
    notification: {
      title: "🌍 Daily Carbon Summary",
      body: `Your carbon footprint today is ${totalCO2.toFixed(2)} kg CO₂`,
    },
  });
}

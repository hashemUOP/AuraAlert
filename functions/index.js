// 1. We switch back to V1 SDK (Standard, no Eventarc)
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

// 2. CRITICAL CONFIGURATION:
// Region: 'europe-west1' (Belgium) - Supported by V1 and close to your database.
// Trigger: Directly listens to Firestore, bypassing the region block.
exports.sendCaregiverNotification = functions.region('europe-west1').firestore
    .document('Notify/{docId}')
    .onUpdate(async (change, context) => {

      const newData = change.after.data();
      const oldData = change.before.data();

      if (!newData || !oldData) return null;

      // 3. Logic: Only run if 'notify' changed to TRUE
      if (newData.notify === true && oldData.notify !== true) {

        console.log(`Triggered for patient: ${newData.patient}`);

        const caregivers = newData.caregivers || [];
        const patientEmail = newData.patient || "Unknown";

        // Find Tokens
        const tokenPromises = caregivers.map(async (email) => {
            const userDoc = await admin.firestore().collection('UsersInfo').doc(email).get();
            if (userDoc.exists) {
                return userDoc.data().fcm_token;
            } else {
                console.log(`No user found for: ${email}`);
                return null;
            }
        });

        const results = await Promise.all(tokenPromises);
        const validTokens = results.filter(token => token != null);

        // Send Notifications
        if (validTokens.length > 0) {
            const payload = {
                notification: {
                    title: "Emergency Alert",
                    body: `Patient ${patientEmail} requires assistance!`,
                }
            };

            try {
                await admin.messaging().sendEachForMulticast({
                    tokens: validTokens,
                    notification: payload.notification
                });
                console.log(`Sent to ${validTokens.length} devices.`);
            } catch (error) {
                console.error("Error sending:", error);
            }
        }

        // RESET: Set 'notify' back to false
        return change.after.ref.update({ notify: false });
      }

      return null;
    });
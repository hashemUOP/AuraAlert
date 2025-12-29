const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.sendCaregiverNotification = functions.region('europe-west1').firestore
    .document('Notify/{docId}')
    .onWrite(async (change, context) => { // CHANGED: onUpdate -> onWrite

      const newData = change.after.data();
      const oldData = change.before.exists ? change.before.data() : null;

      // 1. Exit if document was deleted
      if (!change.after.exists) return null;

      // 2. Logic: Run if 'notify' is TRUE
      // We check if it is TRUE now, AND (it was previously false OR it didn't exist before)
      const isNewNotification = newData.notify === true && (!oldData || oldData.notify !== true);

      if (isNewNotification) {

        console.log(`Triggered for patient: ${newData.patient}`);

        const caregivers = newData.caregivers || [];
        const patientEmail = newData.patient || "Unknown";

        // Find Tokens
        const tokenPromises = caregivers.map(async (email) => {
            // Trim whitespace to ensure email matches ID exactly
            const cleanEmail = email.trim();
            const userDoc = await admin.firestore().collection('UsersInfo').doc(cleanEmail).get();

            if (userDoc.exists) {
                const data = userDoc.data();
                if (data.fcm_token) {
                    return data.fcm_token;
                } else {
                     console.log(`User ${cleanEmail} exists but has no fcm_token`);
                     return null;
                }
            } else {
                console.log(`No user found in UsersInfo for: ${cleanEmail}`);
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
                },
                // Android specific priority
                android: {
                    priority: "high",
                    notification: {
                        channelId: "emergency_channel" // Ensure this exists in Flutter if using channels
                    }
                }
            };

            try {
                const response = await admin.messaging().sendEachForMulticast({
                    tokens: validTokens,
                    notification: payload.notification,
                    android: payload.android
                });
                console.log(`Sent to ${response.successCount} devices. Failures: ${response.failureCount}`);
            } catch (error) {
                console.error("Error sending:", error);
            }
        } else {
            console.log("No valid tokens found for any caregiver.");
        }

        // RESET: Set 'notify' back to false to allow future triggers
        // We use change.after.ref to ensure we update the correct doc
        return change.after.ref.update({ notify: false });
      }

      return null;
    });
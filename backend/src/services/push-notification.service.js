const admin = require('firebase-admin')

const sendNotification = async (tokens, title, body) => {
  try {
    console.log(
      `Sending notification to: ${tokens
        .map((t) => t.substring(0, 8) + '...')
        .join(', ')}`
    )
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: title,
        body: body
      }
    })
  } catch (error) {
    console.error('Error sending notification: ', error)
  }
}

module.exports = {
  sendNotification
}

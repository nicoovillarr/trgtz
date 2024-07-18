const admin = require('firebase-admin')
const userService = require('./user.service')

const Session = require('../models/session.model')

const sendNotification = async (userId, tokens, title, body) => {
  try {
    console.log(
      `Sending notification to: ${tokens
        .map((t) => t.substring(0, 8) + '...')
        .join(', ')}`
    )

    const { firstName } = (await userService.getUserInfo(userId)).toJSON()
    if (title.includes('$name')) {
      title = title.replace('$name', firstName)
    }

    if (body.includes('$name')) {
      body = body.replace('$name', firstName)
    }

    const response = await admin.messaging().sendEachForMulticast({
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

const sendNotificationToFriends = async (userId, title, body) => {
  const friends = await userService.getFriends(userId)
  const tokens = await userService.getUserFirebaseTokens(friends)
  await sendNotification(userId, tokens, title, body)
}

module.exports = {
  sendNotification,
  sendNotificationToFriends
}

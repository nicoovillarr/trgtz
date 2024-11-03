const admin = require('firebase-admin')
const userService = require('./user.service')

const Session = require('../models/session.model')
const User = require('../models/user.model')
const { alertTypes } = require('../config/constants')

const sendNotification = async (userId, tokens, type, body) => {
  try {
    if (tokens == null || tokens.length === 0) return

    const title = alertTypes[type]

    tokens = tokens.reduce((acc, val) => {
      if (acc.includes(val)) return acc
      else acc.push(val)
      return acc
    }, [])

    console.log(
      `Sending notification to: ${tokens
        .map((t) => t.substring(0, 8) + '...')
        .join(', ')}`
    )

    const { firstName } = (await userService.getUserInfo(userId)).toJSON()

    if (body.includes('$name')) {
      body = body.replace('$name', firstName)
    }

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body
      }
    })

    const invalidTokens = []
    response.responses.forEach((result, index) => {
      if (!result.success) {
        const error = result.error
        console.error('Error sending message:', error)
        if (
          error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[index])
        }
      }
    })

    if (invalidTokens.length > 0) {
      await Session.updateMany(
        { 'device.firebaseToken': { $in: invalidTokens } },
        { $unset: { 'device.$.firebaseToken': '' } }
      )
      console.log('Invalid tokens removed:', invalidTokens)
    }
  } catch (error) {
    console.error('Error sending notification: ', error)
  }
}

const sendNotificationToFriends = async (userId, type, body) => {
  const user = await User.findById(userId)
  if (user == null || !user.subscribedAlerts.includes(type)) return

  const friends = await userService.getFriends(userId, {
    status: 'accepted',
    deletedOn: { $eq: null }
  })

  const tokens = await userService.getUserFirebaseTokens(
    friends.map((f) => f.otherUserID)
  )
  
  await sendNotification(userId, tokens, type, body)
}

const sendNotificationToUser = async (userId, type, body) => {
  const user = await User.findById(userId)
  if (user == null || !user.subscribedAlerts.includes(type)) return

  const tokens = await userService.getUserFirebaseTokens([userId])
  await sendNotification(userId, tokens, type, body)
}

module.exports = {
  sendNotification,
  sendNotificationToFriends,
  sendNotificationToUser
}

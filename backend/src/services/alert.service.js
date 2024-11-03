const User = require('../models/user.model')
const Alert = require('../models/alert.model')
const userService = require('./user.service')
const { sendAlertsChannelMessage } = require('../config/websocket')
const { alertTypes } = require('../config/constants')

const sendAlertToFriends = async (userId, type) => {
  const friends = await userService.getFriends(userId, {
    status: 'accepted',
    deletedOn: { $eq: null }
  })
  for (const friend of friends.map((friend) => friend.toJSON())) {
    await addAlert(
      userId,
      friend.recipient === userId ? friend.requester : friend.recipient,
      type
    )
  }
}

const addAlert = async (sent_by, sent_to, type, isSystemAlert = false) => {
  if (sent_by === sent_to && !isSystemAlert) return

  const alert = new Alert({
    sent_by,
    sent_to,
    type,
    isSystemAlert,
    createdOn: new Date()
  })

  await alert.save()

  const user = await User.findById(sent_to)
  user.alerts.push(alert)
  await user.save()

  sent_by = (await userService.getMinUserInfo(sent_by))[0]
  sendAlertsChannelMessage(
    sent_to,
    'NEW_ALERT',
    Object.assign(alert.toJSON(), {
      sent_by
    })
  )

  return alert
}

const markAlertsAsSeen = async (userId) => {
  const alerts = await Alert.find({ sent_to: userId, seen: false })
  alerts.forEach((alert) => {
    alert.seen = true
  })
  await Promise.all(alerts.map((alert) => alert.save()))
}

const deleteAlerts = async (sent_by, sent_to) => {
  await Alert.deleteMany({
    $or: [
      { sent_by, sent_to },
      { sent_by: sent_to, sent_to: sent_by }
    ]
  })
}

const deleteAlert = async (sent_by, sent_to, type) =>
  await Alert.deleteOne({ sent_by, sent_to, type: type })

const isValidAlertType = (type) => Object.keys(alertTypes).includes(type)

module.exports = {
  sendAlertToFriends,
  addAlert,
  markAlertsAsSeen,
  deleteAlerts,
  deleteAlert,
  isValidAlertType
}

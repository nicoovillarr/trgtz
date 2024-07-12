const User = require('../models/user.model')
const Alert = require('../models/alert.model')

const sendAlertToFriends = async (userId, type) => {
  const user = await User.findById(userId)
  const friends = user.friends.filter(
    (friend) => friend.status === 'accepted' && friend.deletedOn === null
  )
  for (const friend of friends) {
    await addAlert(
      userId,
      friend.recipient === userId ? friend.requester : friend.recipient,
      type
    )
  }
}

const addAlert = async (sent_by, sent_to, type) => {
  const alert = new Alert({
    sent_by,
    sent_to,
    type
  })

  await alert.save()

  const user = await User.findById(sent_to)
  user.alerts.push(alert)
  await user.save()

  return alert
}

module.exports = {
  sendAlertToFriends,
  addAlert
}

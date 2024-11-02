const User = require('../models/user.model')
const Session = require('../models/session.model')
const {
  sendUserChannelMessage,
  sendFriendsChannelMessage
} = require('../config/websocket')
const { viewUsers, viewFriends } = require('../config/views')
const mailService = require('./mail.service')
const tokenService = require('./token.service')

const getUsers = async () => await User.find()

const getUserInfo = async (id) => {
  return await viewUsers.findOne({ _id: id })
}

const patchUser = async (id, updates) => {
  const user = await User.findOne({ _id: id })

  const fields = Object.keys(updates).filter((t) =>
    ['firstName', 'email'].includes(t)
  )

  for (const key of fields) {
    user[key] = updates[key]
  }

  await user.save()

  sendUserChannelMessage(
    id,
    'USER_UPDATED',
    fields.reduce((acc, curr) => ({ ...acc, [curr]: updates[curr] }), {})
  )
}

const updatePassword = async (user, newHash) => {
  user.password = newHash

  if (!user.providers.includes('email')) {
    user.providers.push('email')
  }

  await user.save()
}

const sendFriendRequest = async (requester, recipient) => {
  requester.friends.push({
    requester: requester._id,
    recipient: recipient._id
  })
  recipient.friends.push({
    requester: requester._id,
    recipient: recipient._id
  })
  await requester.save()
  await recipient.save()

  sendFriendsChannelMessage(recipient._id, 'FRIEND_REQUEST', requester._id)
}

const userExist = async (id) => (await User.countDocuments({ _id: id })) > 0

const canSendFriendRequest = async (me, other) => {
  if (me._id === other._id) return false

  const existingFriendship = me.friends.find(
    (friend) =>
      ((friend.requester === me._id && friend.recipient == other._id) ||
        (friend.requester == other._id && friend.recipient == me._id)) &&
      friend.status !== 'accepted' &&
      (friend.status === 'rejected' ? friend.deletedOn === null : true)
  )

  return !existingFriendship
}

const answerFriendRequest = async (recipient, requester, answer) => {
  const requesterFriend = requester.friends.find(
    (friend) =>
      friend.recipient.toString() === recipient._id &&
      friend.status === 'pending'
  )

  const recipientFriend = recipient.friends.find(
    (friend) =>
      friend.requester.toString() === requester._id &&
      friend.status === 'pending'
  )

  if (requesterFriend == null || recipientFriend == null) return false

  if (answer === true) {
    requesterFriend.status = 'accepted'
    recipientFriend.status = 'accepted'
  } else {
    requesterFriend.status = 'rejected'
    recipientFriend.status = 'rejected'
  }

  requesterFriend.updatedOn = new Date()
  recipientFriend.updatedOn = new Date()

  await requester.save()
  await recipient.save()

  if (answer) {
    sendFriendsChannelMessage(
      recipient._id,
      'FRIEND_REQUEST_ACCEPTED',
      requester._id
    )
    sendFriendsChannelMessage(
      requester._id,
      'FRIEND_REQUEST_ACCEPTED',
      recipient._id
    )
  }

  return true
}

const getFriends = async (userId, filters = {}) => {
  return await viewFriends.find({ _id: userId, ...filters })
}

const getMinUserInfo = async (ids) => {
  const users = await User.find({ _id: { $in: ids } })
  return users.map((user) => {
    return {
      _id: user._id,
      firstName: user.firstName,
      email: user.email,
      createdAt: user.createdAt
    }
  })
}

const deleteFriend = async (me, friend) => {
  me.friends = me.friends.map((f) => ({
    ...f,
    deletedOn:
      (f.requester == friend._id && f.recipient == me._id) ||
      (f.requester == me._id && f.recipient == friend._id)
        ? new Date()
        : f.deletedOn
  }))

  friend.friends = me.friends.map((f) => ({
    ...f,
    deletedOn:
      (f.requester == friend._id && f.recipient == me._id) ||
      (f.requester == me._id && f.recipient == friend._id)
        ? new Date()
        : f.deletedOn
  }))

  await me.save()
  await friend.save()

  sendFriendsChannelMessage(me._id, 'FRIEND_DELETED', friend._id)
}

const getUserFirebaseTokens = async (ids) => {
  const users = await Session.find({
    userId: { $in: ids },
    device: { $ne: null },
    'device.firebaseToken': { $ne: null }
  })
  return users.map((user) => user.device.firebaseToken)
}

const getPendingFriends = async (userId) =>
  await getFriends(userId, {
    requester: { $ne: userId },
    status: 'pending',
    deletedOn: { $eq: null }
  })

const setAvatarImage = async (id, image) => {
  const user = await User.findById(id)
  user.avatar = image._id
  await user.save()

  sendUserChannelMessage(id, 'USER_UPDATED', {
    avatar: image
  })
}

const hasAccess = async (me, other) => {
  const user = await User.findById(me)
  return (
    user.friends.find(
      (friend) =>
        ((friend.requester == me && friend.recipient == other) ||
          (friend.requester == other && friend.recipient == me)) &&
        friend.status == 'accepted' &&
        friend.deletedOn == null
    ) || user.isSuperAdmin
  )
}

const sendValidationEmail = async (user) => {
  const token = await tokenService.createToken('email_validation', user._id)

  const subject = 'Email validation'
  const link = `${process.env.FRONTEND_URL}/validate?token=${token}`
  const text = `Click here to validate your email: ${link}`
  const html = `<a href="${link}">Click here to validate your email</a>`

  return await mailService.sendNoReplyEmail(user.email, subject, text, html)
}

const validateEmail = async (token) => {
  const userId = await tokenService.consumeToken(token, 'email_validation')
  if (!userId) return null

  const user = await User.findById(userId)
  if (user.emailVerified) return null

  user.emailVerified = true
  await user.save()

  return userId
}

const sendUserEmailVerified = async (userId, email) => {
  const subject = 'Email validated'
  const text = 'Your email has been successfully validated'
  const html = '<p>Your email has been successfully validated</p>'
  return await mailService.sendNoReplyEmail(email, subject, text, html)
}

module.exports = {
  getUsers,
  getUserInfo,
  patchUser,
  sendFriendRequest,
  updatePassword,
  userExist,
  canSendFriendRequest,
  answerFriendRequest,
  getFriends,
  getMinUserInfo,
  deleteFriend,
  getUserFirebaseTokens,
  getPendingFriends,
  setAvatarImage,
  hasAccess,
  sendValidationEmail,
  validateEmail,
  sendUserEmailVerified
}

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
  const editableFields = ['firstName', 'email']
  for (const key of Object.keys(updates).filter((t) =>
    editableFields.includes(t)
  )) {
    user[key] = updates[key]
  }
  await user.save()
  sendUserChannelMessage(
    id,
    'USER_UPDATED',
    Object.keys(updates)
      .filter((t) => editableFields.includes(t))
      .reduce((acc, curr) => ({ ...acc, [curr]: updates[curr] }), {})
  )
}

const updatePassword = async (user, newHash) => {
  user.password = newHash

  if (!user.providers.includes('email')) {
    user.providers.push('email')
  }

  await user.save()
}

const sendFriendRequest = async (requesterId, recipientId) => {
  const requester = await User.findById(requesterId)
  const recipient = await User.findById(recipientId)
  requester.friends.push({
    requester: requesterId,
    recipient: recipientId
  })
  recipient.friends.push({
    requester: requesterId,
    recipient: recipientId
  })
  await requester.save()
  await recipient.save()

  sendFriendsChannelMessage(recipientId, 'FRIEND_REQUEST', requesterId)
}

const userExist = async (id) => (await User.countDocuments({ _id: id })) > 0

const canSendFriendRequest = async (me, other) => {
  if (me === other) return false

  const user = await User.findById(me)
  if (!user) return false

  const existingFriendship = user.friends.find(
    (friend) =>
      ((friend.requester === me && friend.recipient == other) ||
        (friend.requester == other && friend.recipient == me)) &&
      friend.status !== 'accepted' &&
      (friend.status === 'rejected' ? friend.deletedOn === null : true)
  )

  return !existingFriendship
}

const answerFriendRequest = async (recipientId, requesterId, answer) => {
  const requester = await User.findById(requesterId)
  const recipient = await User.findById(recipientId)
  const requesterFriend = requester.friends.find(
    (friend) =>
      friend.recipient.toString() === recipientId && friend.status === 'pending'
  )
  const recipientFriend = recipient.friends.find(
    (friend) =>
      friend.requester.toString() === requesterId && friend.status === 'pending'
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
      recipientId,
      'FRIEND_REQUEST_ACCEPTED',
      requesterId
    )
    sendFriendsChannelMessage(
      requesterId,
      'FRIEND_REQUEST_ACCEPTED',
      recipientId
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
  const meUser = await User.findById(me)
  const friendUser = await User.findById(friend)
  meUser.friends = meUser.friends.map((f) => {
    if (
      (f.requester == friend && f.recipient == me) ||
      (f.requester == me && f.recipient == friend)
    ) {
      f.deletedOn = new Date()
    }
    return f
  })
  friendUser.friends = friendUser.friends.map((f) => {
    if (
      (f.requester == friend && f.recipient == me) ||
      (f.requester == me && f.recipient == friend)
    ) {
      f.deletedOn = new Date()
    }
    return f
  })
  await meUser.save()
  await friendUser.save()

  sendFriendsChannelMessage(me, 'FRIEND_DELETED', friend)
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

  sendUserChannelMessage(id, 'USER_UPDATE', {
    avatar: image
  })
}

const hasAccess = async (me, other) => {
  const user = await User.findById(me)
  return user.friends.find(
    (friend) =>
      ((friend.requester == me && friend.recipient == other) ||
        (friend.requester == other && friend.recipient == me)) &&
      friend.status == 'accepted' &&
      friend.deletedOn == null
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
  return await mailService.sendNoReplyEmail(
    email,
    subject,
    text,
    html
  )
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

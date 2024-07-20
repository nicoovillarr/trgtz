const User = require('../models/user.model')
const Session = require('../models/session.model')
const {
  sendUserChannelMessage,
  sendFriendsChannelMessage
} = require('../config/websocket')
const { viewUsers, viewFriends } = require('../config/views')

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
      email: user.email
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
    expiredOn: { $eq: null }
  })
  return users.map((user) => user.device.firebaseToken)
}

const getPendingFriends = async (userId) =>
  await getFriends(userId, {
    requester: { $ne: userId },
    status: 'pending',
    deletedOn: { $eq: null }
  })

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
  getPendingFriends
}

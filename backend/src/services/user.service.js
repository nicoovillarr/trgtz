const User = require('../models/user.model')

const getUsers = async () => await User.find()

const getUserInfo = async (id) => await User.findById(id).populate('goals')

const patchUser = async (id, updates) => {
  const user = await User.findOne({ _id: id })
  for (const key in updates) {
    user[key] = updates[key]
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
}

const userExist = async (id) => (await User.countDocuments({ _id: id })) > 0

const canSendFriendRequest = async (me, other) => {
  if (me == other) return false
  const requester = await User.findById(me)
  return (
    requester.friends.filter(
      (friend) =>
        (friend.recipient != other && friend.requester != other) ||
        friend.status != 'rejected' ||
        friend.deletedOn == null
    ).length == 0
  )
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
  return true
}

module.exports = {
  getUsers,
  getUserInfo,
  patchUser,
  sendFriendRequest,
  userExist,
  canSendFriendRequest,
  answerFriendRequest
}

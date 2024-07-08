const User = require('../models/user.model')
const mongoose = require('mongoose')
const { hashPassword } = require('./auth.service')
const { Schema } = mongoose

const getUsers = async () => await User.find()

const getUserInfo = async (id) => await User.findById(id)

const patchUser = async (id, updates) => {
  const user = await User.findOne({ _id: id })
  const editableFields = ['firstName', 'email']
  for (const key of Object.keys(updates).filter(t => editableFields.includes(t))) {
    user[key] = updates[key]
  }
  await user.save()
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

const getFriends = async (userId) => {
  const friends = await User.aggregate([
    { $match: { _id: userId } },
    { $unwind: '$friends' },
    {
      $lookup: {
        from: 'users', // nombre de la colección de usuarios
        let: {
          requesterId: '$friends.requester',
          recipientId: '$friends.recipient'
        },
        pipeline: [
          {
            $match: {
              $expr: {
                $cond: [
                  {
                    $eq: ['$$requesterId', userId]
                  },
                  { $eq: ['$_id', '$$recipientId'] },
                  { $eq: ['$_id', '$$requesterId'] }
                ]
              }
            }
          },
          {
            $project: {
              _id: 1,
              email: 1,
              firstName: 1
            }
          }
        ],
        as: 'friendDetails'
      }
    },
    { $unwind: '$friendDetails' },
    {
      $project: {
        _id: 0,
        requester: '$friends.requester',
        recipient: '$friends.recipient',
        status: '$friends.status',
        createdOn: '$friends.createdOn',
        updatedOn: '$friends.updatedOn',
        deletedOn: '$friends.deletedOn',
        friendDetails: '$friendDetails'
      }
    }
  ])

  return friends
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
  getMinUserInfo
}

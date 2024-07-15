const User = require('../models/user.model')
const mongoose = require('mongoose')
const { viewUsers } = require('../config/views')

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
  return true
}

const getFriends = async (userId) => {
  const db = mongoose.connection.db
  const coll = db.collection('users')
  const agg = [
    {
      $match: { _id: userId }
    },
    {
      $unwind: {
        path: '$friends'
      }
    },
    {
      $project: {
        friends: true,
        requester: '$friends.requester',
        recipient: '$friends.recipient'
      }
    },
    {
      $lookup: {
        from: 'users',
        let: {
          currentId: '$_id',
          requesterId: '$friends.requester',
          recipientId: '$friends.recipient'
        },
        pipeline: [
          {
            $match: {
              $expr: {
                $or: [
                  {
                    $and: [
                      {
                        $eq: ['$_id', '$$recipientId']
                      },
                      {
                        $eq: ['$$requesterId', '$$currentId']
                      }
                    ]
                  },
                  {
                    $and: [
                      {
                        $eq: ['$_id', '$$requesterId']
                      },
                      {
                        $eq: ['$$recipientId', '$$currentId']
                      }
                    ]
                  }
                ]
              }
            }
          },
          {
            $project: {
              _id: true,
              email: true,
              firstName: true
            }
          }
        ],
        as: 'friendDetails'
      }
    },
    {
      $project: {
        _id: false,
        requester: '$friends.requester',
        recipient: '$friends.recipient',
        status: '$friends.status',
        createdOn: '$friends.createdOn',
        updatedOn: '$friends.updatedOn',
        deletedOn: '$friends.deletedOn',
        friendDetails: '$friendDetails'
      }
    }
  ]
  const cursor = coll.aggregate(agg)
  const result = await cursor.toArray().then((res) => res)
  return result.map((f) => {
    f.friendDetails = f.friendDetails.find((fd) => fd._id != userId)
    return f
  })
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
  deleteFriend
}

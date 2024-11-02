const userService = require('../services/user.service')
const authService = require('../services/auth.service')
const alertService = require('../services/alert.service')
const pushNotificationService = require('../services/push-notification.service')
const imageService = require('../services/image.service')
const goalService = require('../services/goal.service')
const User = require('../models/user.model')
const { sendUserChannelMessage } = require('../config/websocket')

const getUserProfile = async (req, res) => {
  try {
    const me = req.user
    const { user } = req.params

    const userInfo = await userService.getUserInfo(user)
    if (userInfo == null) {
      res.status(400).json({ message: `User with id ${user} not found.` })
      return
    }

    const json = userInfo.toJSON()

    if (me != user && !(await userService.hasAccess(me, user))) {
      json.goals = json.goals
        .filter((g) => g.deletedOn == null)
        .map((g) => ({
          _id: g._id,
          title: g.title,
          year: g.year,
          description: g.description,
          completedOn: g.completedOn,
          createdOn: g.createdOn
        }))
      delete json.alerts
      delete json.sessions
      delete json.firebaseTokens
    }

    if (me == user) {
      await alertService.markAlertsAsSeen(user)
    }

    res.status(200).json(json)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting user: ', error)
  }
}

const patchUser = async (req, res) => {
  try {
    const id = req.user
    const updates = req.body

    await userService.patchUser(id, updates)

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error updating user: ', error)
  }
}

const updatePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body

    const user = await User.findById(req.user)
    if (user.providers.includes('email')) {
      const validPassword = await authService.validatePassword(
        user,
        oldPassword
      )

      if (!validPassword) {
        res.status(400).json({ message: 'Invalid credentials.' })
        return
      }
    }

    const hash = await authService.hashPassword(newPassword)
    await userService.updatePassword(user, hash)

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error updating the password:', error)
  }
}

const sendFriendRequest = async (req, res) => {
  try {
    const _id = req.user
    const { recipientId } = req.body
    if (!(await userService.userExist(recipientId))) {
      res.status(400).json({ message: 'Recipient not found.' })
      return
    }

    const me = await User.findById(_id)
    const other = await User.findById(recipientId)

    if (!(await userService.canSendFriendRequest(me, other))) {
      res
        .status(405)
        .json({ message: 'You are not allowed to send a friend request now.' })
      return
    }

    await userService.sendFriendRequest(me, other)
    await alertService.addAlert(_id, recipientId, 'friend_requested')

    const recipientToken = await userService.getUserFirebaseTokens([
      recipientId
    ])

    await pushNotificationService.sendNotification(
      _id,
      recipientToken,
      'New friend request',
      '$name wants to be your friend!'
    )

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error sending friend request: ', error)
  }
}

const answerFriendRequest = async (req, res) => {
  try {
    const _id = req.user
    const { requesterId, answer: isAccepted } = req.body

    const user = await User.findById(_id)
    const requester = await User.findById(requesterId)

    if (requester == null) {
      res.status(400).json({ message: 'Requester not found.' })
      return
    }

    const answered = await userService.answerFriendRequest(
      user,
      requester,
      isAccepted
    )

    if (!answered) {
      res.status(400).json({ message: 'Friend request not found.' })
      return
    }

    if (isAccepted) {
      await alertService.deleteAlert(
        requester._id,
        user._id,
        'friend_requested'
      )
      await alertService.addAlert(user._id, requester._id, 'friend_accepted')
      await alertService.addAlert(requester._id, user._id, 'friend_accepted')

      const recipientToken = await userService.getUserFirebaseTokens([
        requester._id
      ])
      await pushNotificationService.sendNotification(
        user._id,
        recipientToken,
        'Friend request accepted',
        '$name and you are now friends!'
      )
    }

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error answering friend request: ', error)
  }
}

const deleteFriend = async (req, res) => {
  try {
    const { otherUser: otherUserId } = req.params

    const user = await User.findById(req.user)
    const otherUser = await User.findById(otherUserId)

    if (otherUser == null) {
      res.status(400).json({ message: 'Friend not found.' })
      return
    }

    await userService.deleteFriend(user, otherUser)

    await alertService.deleteAlerts(user._id, otherUser._id)

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error deleting friend: ', error)
  }
}

const getFriends = async (req, res) => {
  try {
    const friends = await userService.getFriends(req.user, {
      status: 'accepted',
      deletedOn: { $eq: null }
    })
    res.status(200).json(friends)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting friends: ', error)
  }
}

const getPendingFriends = async (req, res) => {
  try {
    const pendingFriends = await userService.getPendingFriends(req.user)
    res.status(200).json(pendingFriends)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting pending friends: ', error)
  }
}

const setProfileImage = async (req, res) => {
  try {
    const _id = req.user

    const image = await imageService.uploadImage(req, res, _id)
    await userService.setAvatarImage(_id, image)
    
    res.status(204).json(image)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error setting profile image: ', error)
  }
}

const getUserGoals = async (req, res) => {
  try {
    const me = req.user
    const { user } = req.params
    const { year } = req.query

    if (me != user && !(await userService.hasAccess(me, user))) {
      res.status(403).end()
      return
    }

    const goals = await goalService.getGoals(user, year)
    res.status(200).json(goals)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting goals: ', error)
  }
}

const getUserFriends = async (req, res) => {
  try {
    const me = req.user
    const { user } = req.params
    const { status } = req.query

    if (
      me != user &&
      (!(await userService.hasAccess(me, user)) ||
        (status != null && status != '' && status != 'accepted'))
    ) {
      res.status(403).end()
      return
    }

    const friends = await userService.getFriends(user, {
      status: status ?? 'accepted',
      deletedOn: { $eq: null }
    })

    res.status(200).json(friends)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting friends: ', error)
  }
}

const sendValidationEmail = async (req, res) => {
  try {
    const user = await User.findById(req.user)
    if (user.emailValidated) {
      res.status(400).json({ message: 'Email already validated.' })
      return
    }

    if (await userService.sendValidationEmail(user)) res.status(204).end()
    else throw new Error('Error sending validation email.')
  } catch (error) {
    res.status(500).json(error)
    console.error('Error sending validation email: ', error)
  }
}

const validateEmail = async (req, res) => {
  try {
    const { token } = req.query
    const userId = await userService.validateEmail(token)
    if (userId != null) {
      const user = await User.findById(userId)

      await userService.sendUserEmailVerified(user._id, user.email)

      sendUserChannelMessage(userId, 'USER_EMAIL_VERIFIED', true)
      
      res.status(204).end()
    } else throw new Error('Error validating email.')
  } catch (error) {
    res.status(500).json(error)
    console.error('Error validating email: ', error)
  }
}

module.exports = {
  getUserProfile,
  patchUser,
  updatePassword,
  sendFriendRequest,
  answerFriendRequest,
  deleteFriend,
  getFriends,
  getPendingFriends,
  setProfileImage,
  getUserGoals,
  getUserFriends,
  sendValidationEmail,
  validateEmail
}

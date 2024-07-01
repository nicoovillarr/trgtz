const userService = require('../services/user.service')

const getMe = async (req, res) => {
  try {
    const user = (await userService.getUserInfo(req.user)).toJSON()
    res.status(200).json(user)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting users: ', error)
  }
}

const patchUser = async (req, res) => {
  try {
    const { id } = req.params
    const updates = req.body
    await userService.patchUser(id, updates)
    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error updating user: ', error)
  }
}

const sendFriendRequest = async (req, res) => {
  try {
    const _id = req.user
    const { recipientId } = req.body
    if (!userService.userExist(recipientId)) {
      res.status(400).json({ message: 'Recipient not found.' })
      return
    }

    if (!(await userService.canSendFriendRequest(_id, recipientId))) {
      res
        .status(405)
        .json({ message: 'You are not allowed to send a friend request now.' })
      return
    }

    await userService.sendFriendRequest(_id, recipientId)

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error sending friend request: ', error)
  }
}

const answerFriendRequest = async (req, res) => {
  try {
    const _id = req.user
    const { requesterId, answer } = req.body
    if (!(await userService.userExist(requesterId))) {
      res.status(400).json({ message: 'Requester not found.' })
      return
    }

    const answered = await userService.answerFriendRequest(
      _id,
      requesterId,
      answer
    )
    if (!answered) {
      res.status(400).json({ message: 'Friend request not found.' })
      return
    }

    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error answering friend request: ', error)
  }
}

module.exports = {
  getMe,
  patchUser,
  sendFriendRequest,
  answerFriendRequest
}

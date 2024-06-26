const userService = require('../services/user.service')

const getMe = async (req, res) => {
  try {
    const user = (await userService.getUserInfo(req.user)).toJSON()
    delete user.sessions
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

module.exports = {
  getMe,
  patchUser
}

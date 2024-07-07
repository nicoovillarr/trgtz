const userService = require('../services/user.service')
const authService = require('../services/auth.service')

const getMe = async (req, res) => {
  try {
    const user = await userService.getUserInfo(req.user)
    await user.populate('goals')
    const json = user.toJSON()
    delete json.sessions
    res.status(200).json(json)
  } catch (error) {
    res.status(500).json(error)
    console.error('Error getting users: ', error)
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
    const user = await userService.getUserInfo(req.user)
    const validPassword = await authService.validatePassword(user, oldPassword)
    if (!validPassword) {
      res.status(400).json({ message: 'Invalid credentials.' })
      return
    }
    const hash = await authService.hashPassword(newPassword)
    await userService.updatePassword(user, hash)
    res.status(204).end()
  } catch (error) {
    res.status(500).json(error)
    console.error('Error updating the password:', error)
  }
}

module.exports = {
  getMe,
  patchUser,
  updatePassword
}

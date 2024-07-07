const User = require('../models/user.model')
const { hashPassword } = require('./auth.service')

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

module.exports = {
  getUsers,
  getUserInfo,
  patchUser,
  updatePassword
}

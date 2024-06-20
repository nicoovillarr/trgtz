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

module.exports = {
  getUsers,
  getUserInfo,
  patchUser
}

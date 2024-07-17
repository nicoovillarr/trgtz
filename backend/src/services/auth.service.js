const User = require('../models/user.model')
const Session = require('../models/session.model')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

const signup = async (firstName, email, password) => {
  const user = new User({
    firstName,
    email,
    password
  })
  await user.save()
  const json = user.toJSON()
  delete json.goals
  return json
}

const login = async (email, password) => {
  const user = await User.findOne({ email })
  if (user == null) return null
  if (!(await validatePassword(user, password))) return null
  return user
}

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10)
  return await bcrypt.hash(password, salt)
}

const checkEmailInUse = async (email) =>
  (await User.findOne({ email })) !== null

const validatePassword = async (user, password) =>
  await bcrypt.compare(password, user.password).then((res) => res)

module.exports = {
  signup,
  login,
  checkEmailInUse,
  hashPassword,
  validatePassword
}

const User = require('../models/user.model')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

const signup = async (firstName, email, password) => {
  const user = new User({
    firstName,
    email,
    password
  })
  await user.save()
  return user
}

const login = async (email, password) => {
  const user = await User.findOne({ email })
  if (user == null) return null
  const validPassword = await bcrypt.compare(password, user.password)
  if (!validPassword) return null
  return user
}

const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10)
  return await bcrypt.hash(password, salt)
}

const checkEmailInUse = async (email) =>
  (await User.findOne({ email })) !== null

const createJWT = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '15m'
  })

module.exports = {
  signup,
  login,
  checkEmailInUse,
  hashPassword,
  createJWT
}

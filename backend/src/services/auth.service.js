const { OAuth2Client } = require('google-auth-library')
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID)

const User = require('../models/user.model')
const Image = require('../models/image.model')
const bcrypt = require('bcryptjs')

const signup = async (
  firstName,
  email,
  hash,
  provider = 'email',
  photoUrl = null
) => {
  const user = new User({
    firstName,
    email,
    password: hash,
    providers: [provider]
  })

  if (photoUrl) {
    const image = new Image({
      url: photoUrl,
      user: user._id,
      createdOn: new Date()
    })
    await image.save()
    user.avatar = image._id
  }

  if (provider === 'google') {
    user.emailVerified = true
  }

  await user.save()
  const json = user.toJSON()
  delete json.goals
  return json
}

const login = async (email, password) => {
  const user = await User.findOne({ email })
  if (user == null) return null

  if (!user.providers.includes('email') || user.password == null) return null

  if (!(await validatePassword(user, password))) return null

  if (user.providers.indexOf('email') === -1) {
    user.providers.push('email')
    await user.save()
  }

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

const verifyGoogleToken = async (idToken) => {
  const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: process.env.GOOGLE_CLIENT_ID
  })

  return ticket.getPayload()
}

const addProvider = async (user, provider) => {
  if (user.providers.indexOf(provider) !== -1) {
    return false
  }

  user.providers.push(provider)
  await user.save()
  return true
}

module.exports = {
  signup,
  login,
  checkEmailInUse,
  hashPassword,
  validatePassword,
  verifyGoogleToken,
  addProvider
}

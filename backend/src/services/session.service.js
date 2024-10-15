const jwt = require('jsonwebtoken')
const Session = require('../models/session.model')
const User = require('../models/user.model')

const createJWT = async (
  userId,
  firebaseToken,
  type,
  version,
  manufacturer,
  model,
  isVirtual,
  serialNumber,
  ip,
  provider = 'email'
) => {
  const token = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: '15d'
  })

  const session = new Session({
    userId: userId,
    token: token,
    lastIPAddress: ip,
    provider,
    device: {
      firebaseToken,
      type,
      version,
      manufacturer,
      model,
      isVirtual,
      serialNumber
    }
  })

  await session.save()

  const user = await User.findById(userId)
  user.sessions.push(session._id)
  await user.save()

  return token
}

const updateSession = async (token, ip) => {
  const session = await Session.findOne({ token })
  session.lastIPAddress = ip
  session.lastAccesedOn = new Date()
  await session.save()
}

const updateFirebaseToken = async (token, firebaseToken) => {
  const session = await Session.findOne({ token })
  session.device.firebaseToken = firebaseToken
  await session.save()
}

const getSession = async (token) =>
  await Session.findOne({ token, expiredOn: { $eq: null } })

const deleteSession = async (token) => {
  const session = await Session.findOne({ token })
  session.expiredOn = new Date()
  await session.save()
}

const updateSessionProvider = async (token, provider) => {
  const session = await Session.findOne({ token })
  session.provider = provider
  await session.save()
}

module.exports = {
  createJWT,
  updateSession,
  updateFirebaseToken,
  getSession,
  deleteSession,
  updateSessionProvider
}

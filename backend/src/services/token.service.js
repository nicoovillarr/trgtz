const Token = require('../models/tokens.model')
const bcrypt = require('bcryptjs')

const createToken = async (type, user) => {
  const hash = await bcrypt.hash(new Date().getTime().toString(36), 10)
  const newToken = new Token({
    token: Buffer.from(hash).toString('base64'),
    user,
    type
  })
  await newToken.save()

  return newToken.token
}

const consumeToken = async (token, type) => {
  const tokenDoc = await Token.findOne({ token, type, used: false })
  if (tokenDoc == null) return false

  tokenDoc.used = true
  await tokenDoc.save()

  return tokenDoc.user
}

const getToken = async (token, type) => await Token.findOne({ token, type, used: false })

module.exports = {
  createToken,
  consumeToken,
  getToken
}

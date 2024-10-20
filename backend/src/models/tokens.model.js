const mongoose = require('mongoose')
const tokenService = require('../services/token.service')

const tokenSchema = new mongoose.Schema({
  token: {
    type: String,
    required: true,
    unique: true
  },
  type: {
    type: String,
    required: true,
    enum: ['password_reset']
  },
  user: {
    type: String,
    ref: 'User'
  },
  createdOn: {
    type: Date,
    default: Date.now,
    expires: 43200
  },
  used: {
    type: Boolean,
    default: false
  }
})

const Token = mongoose.model('Token', tokenSchema)

module.exports = Token

const mongoose = require('mongoose')
const { alertTypes } = require('../config/constants')

const alertSchema = new mongoose.Schema({
  sent_by: {
    type: String,
    ref: 'User',
    required: true
  },
  sent_to: {
    type: String,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    required: true,
    enum: Object.keys(alertTypes)
  },
  isSystemAlert: {
    type: Boolean,
    required: true,
    default: false
  },
  seen: {
    type: Boolean,
    required: true,
    default: false
  },
  createdOn: {
    type: Date,
    required: true,
    default: new Date()
  }
})

const Alert = mongoose.model('Alert', alertSchema)

module.exports = Alert
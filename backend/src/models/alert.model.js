const mongoose = require('mongoose')

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
    enum: [
      'friend_requested',
      'friend_accepted',
      'goal_created',
      'goal_completed',
      'milestone_completed',
      'goal_reaction'
    ]
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

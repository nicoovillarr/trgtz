const mongoose = require('mongoose')
const { report } = require('../routes/goal.route')

const reportSchema = new mongoose.Schema({
  user: {
    type: String,
    ref: 'User',
    required: true
  },
  entity_type: {
    type: String,
    required: true,
    enum: ['goal', 'user', 'comment']
  },
  entity_id: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true,
    enum: ['spam', 'harassment', 'hate speech', 'violence', 'nudity', 'other']
  },
  reason: {
    type: String,
    required: false,
    default: null
  },
  status: {
    type: String,
    required: true,
    enum: ['pending', 'resolved', 'rejected'],
    default: 'pending'
  },
  resolution: {
    type: String,
    required: false,
    default: null
  },
  createdOn: {
    type: Date,
    required: true
  }
})

const Report = mongoose.model('Report', reportSchema)

module.exports = Report

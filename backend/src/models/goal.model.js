const mongoose = require('mongoose')

const goalSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: false,
    default: null
  },
  year: {
    type: Number,
    required: true
  },
  createdOn: {
    type: String,
    required: true,
    default: new Date()
  },
  completedOn: {
    type: Date,
    required: false,
    default: null
  },
  deletedOn: {
    type: Date,
    required: false,
    default: null
  }
})

const Goal = mongoose.model('Goal', goalSchema)

module.exports = Goal

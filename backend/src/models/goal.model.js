const mongoose = require('mongoose')

const goalSchema = new mongoose.Schema({
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
    required: true
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

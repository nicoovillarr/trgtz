const mongoose = require('mongoose')

const goalSchema = new mongoose.Schema({
  user: {
    type: String,
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
  milestones: [
    {
      title: {
        type: String,
        required: true
      },
      createdOn: {
        type: Date,
        required: true,
        default: new Date()
      },
      completedOn: {
        type: Date,
        required: false,
        default: null
      }
    }
  ],
  events: [
    {
      type: {
        type: String,
        required: true,
        enum: [
          'goal_created',
          'goal_updated',
          'milestone_created',
          'milestone_completed',
          'goal_completed'
        ]
      },
      createdOn: {
        type: Date,
        required: true
      }
    }
  ],
  reactions: [
    {
      user: {
        type: String,
        ref: 'User',
        required: true
      },
      type: {
        type: String,
        required: true,
        enum: ['like', 'love', 'happy', 'cheer']
      }
    }
  ],
  comments: [
    {
      user: {
        type: String,
        ref: 'User',
        required: true
      },
      text: {
        type: String,
        required: true
      },
      createdOn: {
        type: Date,
        required: true
      }
    }
  ],
  createdOn: {
    type: Date,
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

const mongoose = require('mongoose')
const { Schema } = mongoose

const generateHexId = () =>
  Math.floor(Math.random() * 0xffffff)
    .toString(16)
    .padStart(6, '0')

const userSchema = new Schema(
  {
    _id: {
      type: String,
      default: generateHexId
    },
    email: {
      type: String,
      required: true
    },
    password: {
      type: String,
      required: true
    },
    firstName: {
      type: String,
      required: true
    },
    goals: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Goal'
      }
    ],
    friends: [
      {
        requester: {
          type: String,
          ref: 'User'
        },
        recipient: {
          type: String,
          ref: 'User'
        },
        status: {
          type: String,
          enum: ['pending', 'accepted', 'rejected'],
          default: 'pending'
        },
        createdOn: {
          type: Date,
          default: new Date()
        },
        updatedOn: {
          type: Date,
          required: false,
          default: null
        },
        deletedOn: {
          type: Date,
          required: false,
          default: null
        }
      }
    ],
    sessions: [
      {
        type: String
      }
    ]
  },
  {
    timestamps: true,
    toJSON: {
      transform(doc, ret) {
        delete ret.password
        delete ret.sessions
      }
    }
  }
)

const User = mongoose.model('User', userSchema)

module.exports = User

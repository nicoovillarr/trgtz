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
    emailVerified: {
      type: Boolean,
      required: false,
      default: false
    },
    password: {
      type: String,
      required: false,
      default: null
    },
    firstName: {
      type: String,
      required: true
    },
    providers: [
      {
        type: String,
        enum: ['email', 'google', 'apple'],
        required: true,
        default: ['email'],
        unique: true
      }
    ],
    avatar: {
      type: Schema.Types.ObjectId,
      ref: 'Image'
    },
    goals: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Goal'
      }
    ],
    alerts: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Alert'
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
        type: Schema.Types.ObjectId,
        ref: 'Session'
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
